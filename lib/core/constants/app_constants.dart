// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'SELK Warehouse';
  static const String appVersion = '1.0.0';

  // Configuración de la aplicación
  static const int tokenRefreshThreshold = 300; // 5 minutos en segundos
  static const int maxRetryAttempts = 3;
  static const Duration requestTimeout = Duration(seconds: 30);

  // Configuración de logout automático
  static const int logoutHour = 16; // 16:00 horas
  static const int logoutMinute = 0;

  // Configuración de base de datos local
  static const String databaseName = 'selk_warehouse.db';
  static const int databaseVersion = 1;

  // Keys para SharedPreferences
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyDeviceId = 'device_id';
  static const String keyLastLogin = 'last_login';

  // Módulos de la aplicación
  static const List<String> modules = ['colocacion', 'entrada', 'recogida'];
}
