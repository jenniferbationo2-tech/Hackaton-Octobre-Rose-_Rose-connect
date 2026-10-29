import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// URL de l'API, fournie au lancement :
/// flutter run --dart-define=API_URL=http://192.168.1.10:3000/api
/// Par défaut : l'hôte de la machine vu depuis l'émulateur Android.
/// Version web servie par l'API : une adresse relative (« /api ») suffit,
/// elle est complétée par l'adresse de la page.
const _apiUrlSetting = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:3000/api',
);
final _apiUrl = _apiUrlSetting.startsWith('/')
    ? Uri.base.resolve(_apiUrlSetting).toString()
    : _apiUrlSetting;

enum AppErrorType {
  network,
  timeout,
  server,
  validation,
  unauthorized,
  conflict,
  notFound,
  rateLimited,
  aiUnavailable,
}

/// Erreur unique remontée aux écrans, avec un message affichable.
class AppException implements Exception {
  const AppException(this.type, this.message);

  final AppErrorType type;
  final String message;

  @override
  String toString() => 'AppException($type): $message';
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _apiUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/json'},
            ));

  final Dio _dio;

  /// Faux tant qu'aucune URL n'est fournie au lancement : les modules
  /// utilisent alors directement leurs données embarquées.
  static const isConfigured = bool.hasEnvironment('API_URL');

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<T> post<T>(String path, Object body,
          {Duration? timeout, String? token}) =>
      _send(() => _dio.post<dynamic>(
            path,
            data: body,
            options: Options(receiveTimeout: timeout, headers: _auth(token)),
          ));

  Future<T> delete<T>(String path, {String? token}) => _send(
      () => _dio.delete<dynamic>(path, options: Options(headers: _auth(token))));

  Map<String, String>? _auth(String? token) =>
      token == null ? null : {'Authorization': 'Bearer $token'};

  /// Lit l'enveloppe { success, data, error } et renvoie `data`.
  Future<T> _send<T>(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is Map<String, dynamic> && body['success'] == true) {
        return body['data'] as T;
      }
      throw const AppException(
          AppErrorType.server, 'Réponse inattendue du serveur.');
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  AppException _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(AppErrorType.timeout,
            'Le serveur met trop de temps à répondre. Réessayez.');
      case DioExceptionType.connectionError:
        return const AppException(AppErrorType.network,
            'Pas de connexion. Vérifiez votre accès à internet.');
      default:
        break;
    }

    final data = e.response?.data;
    final error = data is Map<String, dynamic> ? data['error'] : null;
    final code = error is Map<String, dynamic> ? error['code'] : null;
    final message = error is Map<String, dynamic> && error['message'] is String
        ? error['message'] as String
        : 'Une erreur est survenue. Réessayez plus tard.';

    final type = switch (code) {
      'VALIDATION_ERROR' => AppErrorType.validation,
      'UNAUTHORIZED' || 'INVALID_CREDENTIALS' => AppErrorType.unauthorized,
      'ACCOUNT_EXISTS' => AppErrorType.conflict,
      'NOT_FOUND' => AppErrorType.notFound,
      'RATE_LIMITED' => AppErrorType.rateLimited,
      'AI_UNAVAILABLE' => AppErrorType.aiUnavailable,
      _ => AppErrorType.server,
    };
    return AppException(type, message);
  }
}
