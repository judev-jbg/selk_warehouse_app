// lib/core/error/exceptions.dart
/// Excepción base de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Excepción de servidor
class ServerException extends AppException {
  const ServerException(String message, [String? code]) : super(message, code);
}

/// Excepción de caché/almacenamiento local
class CacheException extends AppException {
  const CacheException(String message, [String? code]) : super(message, code);
}

/// Excepción de red
class NetworkException extends AppException {
  const NetworkException(String message, [String? code]) : super(message, code);
}

/// Excepción de autenticación
class AuthException extends AppException {
  const AuthException(String message, [String? code]) : super(message, code);
}

/// Excepción de validación
class ValidationException extends AppException {
  const ValidationException(String message, [String? code])
      : super(message, code);
}
