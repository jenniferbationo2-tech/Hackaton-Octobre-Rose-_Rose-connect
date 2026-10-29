import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/preferences.dart';
import 'auth_models.dart';
import 'auth_service.dart';

const _statusKey = 'auth_status';
const _sessionKey = 'auth_session';

/// Session courante, restaurée au démarrage depuis le téléphone.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final rawSession = prefs.getString(_sessionKey);
    if (rawSession != null) {
      try {
        return AuthState.signedIn(
            Session.fromJson(jsonDecode(rawSession) as Map<String, dynamic>));
      } on Object {
        prefs.remove(_sessionKey);
      }
    }
    return prefs.getString(_statusKey) == AuthStatus.guest.name
        ? const AuthState.guest()
        : const AuthState.onboarding();
  }

  AuthService get _service => ref.read(authServiceProvider);

  Future<void> continueAsGuest() async {
    await ref
        .read(sharedPreferencesProvider)
        .setString(_statusKey, AuthStatus.guest.name);
    state = const AuthState.guest();
  }

  Future<void> register({
    required String firstName,
    required String identifier,
    required String password,
  }) async {
    final session = await _service.register(
      firstName: firstName,
      identifier: identifier,
      password: password,
    );
    await _signIn(session);
  }

  Future<void> login(
      {required String identifier, required String password}) async {
    await _signIn(
        await _service.login(identifier: identifier, password: password));
  }

  /// Retour en mode sans compte : l'application reste utilisable.
  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_sessionKey);
    await prefs.setString(_statusKey, AuthStatus.guest.name);
    state = const AuthState.guest();
  }

  Future<void> deleteAccount() async {
    final session = state.session;
    if (session != null) await _service.deleteAccount(session);
    await logout();
  }

  Future<void> _signIn(Session session) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    await prefs.setString(_statusKey, AuthStatus.signedIn.name);
    state = AuthState.signedIn(session);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
