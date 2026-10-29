import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/api_client.dart';
import '../../core/services/preferences.dart';
import 'auth_models.dart';

/// Contrat d'authentification. Voir docs/API_AUTH.md pour les routes Node.
abstract interface class AuthService {
  Future<Session> register({
    required String firstName,
    required String identifier,
    required String password,
  });

  Future<Session> login({required String identifier, required String password});

  Future<void> deleteAccount(Session session);
}

final authServiceProvider = Provider<AuthService>((ref) {
  if (ApiClient.isConfigured) return ApiAuthService(ref.watch(apiClientProvider));
  // Tant que l'API n'est pas branchée : comptes enregistrés sur le téléphone.
  return LocalAuthService(ref.watch(sharedPreferencesProvider));
});

/// Identifiants : e-mail, ou numéro burkinabè (8 chiffres, +226 facultatif).
abstract final class Identifier {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Forme normalisée, ou null si l'identifiant n'est pas valide.
  static String? normalize(String input) {
    final value = input.trim();
    if (_email.hasMatch(value)) return value.toLowerCase();
    var digits = value.replaceAll(RegExp(r'[\s.\-()]'), '');
    if (digits.startsWith('+226')) digits = digits.substring(4);
    if (digits.startsWith('00226')) digits = digits.substring(5);
    if (RegExp(r'^\d{8}$').hasMatch(digits)) return '+226$digits';
    return null;
  }
}

class ApiAuthService implements AuthService {
  ApiAuthService(this._api);

  final ApiClient _api;

  @override
  Future<Session> register({
    required String firstName,
    required String identifier,
    required String password,
  }) async {
    final data = await _api.post<Map<String, dynamic>>('/auth/register', {
      'firstName': firstName,
      'identifier': identifier,
      'password': password,
    });
    return Session.fromJson(data);
  }

  @override
  Future<Session> login(
      {required String identifier, required String password}) async {
    final data = await _api.post<Map<String, dynamic>>(
        '/auth/login', {'identifier': identifier, 'password': password});
    return Session.fromJson(data);
  }

  @override
  Future<void> deleteAccount(Session session) =>
      _api.delete<dynamic>('/auth/me', token: session.token);
}

/// Comptes conservés sur le téléphone (mot de passe salé et haché).
/// Solution provisoire pour le prototype, en attendant l'API.
class LocalAuthService implements AuthService {
  LocalAuthService(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'local_accounts';

  Map<String, dynamic> _accounts() {
    final raw = _prefs.getString(_key);
    return raw == null ? {} : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _save(Map<String, dynamic> accounts) =>
      _prefs.setString(_key, jsonEncode(accounts));

  String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  String _randomToken() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(24, (_) => random.nextInt(256)));
  }

  @override
  Future<Session> register({
    required String firstName,
    required String identifier,
    required String password,
  }) async {
    final accounts = _accounts();
    if (accounts.containsKey(identifier)) {
      throw const AppException(AppErrorType.conflict,
          'Un compte existe déjà avec cet identifiant. Connectez-vous.');
    }
    final salt = _randomToken();
    final user = AppUser(
      id: _randomToken(),
      firstName: firstName,
      identifier: identifier,
    );
    accounts[identifier] = {
      'user': user.toJson(),
      'salt': salt,
      'hash': _hash(salt, password),
    };
    await _save(accounts);
    return Session(token: _randomToken(), user: user);
  }

  @override
  Future<Session> login(
      {required String identifier, required String password}) async {
    final account = _accounts()[identifier] as Map<String, dynamic>?;
    if (account == null ||
        account['hash'] != _hash(account['salt'] as String, password)) {
      throw const AppException(AppErrorType.unauthorized,
          'Identifiant ou mot de passe incorrect.');
    }
    return Session(
      token: _randomToken(),
      user: AppUser.fromJson(account['user'] as Map<String, dynamic>),
    );
  }

  @override
  Future<void> deleteAccount(Session session) async {
    final accounts = _accounts()..remove(session.user.identifier);
    await _save(accounts);
  }
}
