// lib/core/constants/api_constants.dart
class ApiConstants {
  // URL base de la API
  static String get baseUrl {
    // Para desarrollo, usar IP de red
    // Para producción, usar el servidor real
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    if (isProduction) {
      return 'https://tu-servidor-produccion.com/api/v1';
    } else {
      return 'http://192.168.1.50:3000/api/v1';
    }
  }

  // Endpoints de autenticación
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';
  static const String auditLogsEndpoint = '/auth/audit-logs';
  static const String verifyTokenEndpoint = '/auth/verify-token';

  // Endpoints de módulos (para implementar después)
  static const String colocacionEndpoint = '/colocacion';
  static const String entradaEndpoint = '/entrada';
  static const String recogidaEndpoint = '/recogida';

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String authorizationHeader = 'Authorization';
  static const String deviceIdHeader = 'Device-ID';
  static const String userAgentHeader = 'User-Agent';

  // Valores de headers
  static const String contentTypeJson = 'application/json';
  static const String userAgentValue = 'SELK-Warehouse-App/1.0.0';
}
