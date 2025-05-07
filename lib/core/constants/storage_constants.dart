/// Constantes para almacenamiento local

class StorageConstants {
  // Claves para Shared Preferences
  static const String cachedUser = 'CACHED_USER';
  static const String authToken = 'AUTH_TOKEN';
  static const String refreshToken = 'REFRESH_TOKEN';

  // Nombres de tablas SQLite
  static const String dbName = 'selk_warehouse.db';
  static const String productsTable = 'products';
  static const String locationsTable = 'locations';
  static const String scansTable = 'scans';
  static const String deliveryNotesTable = 'delivery_notes';
  static const String labelsTable = 'labels';

  // Versión de la base de datos
  static const int dbVersion = 1;
}
