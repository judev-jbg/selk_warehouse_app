/// Excepciones personalizadas para la aplicación

/// Excepción para errores de servidor
class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}

/// Excepción para errores de caché local
class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}

/// Excepción para errores de conexión
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

/// Excepción para errores de autenticación
class AuthException implements Exception {
  final String message;

  AuthException(this.message);
}

/// Excepción para errores relacionados con dispositivos (escáner, impresora)
class DeviceException implements Exception {
  final String message;

  DeviceException(this.message);
}
