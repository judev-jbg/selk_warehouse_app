/// Constantes relacionadas con la API

class ApiConstants {
  // URLs base
  static const String baseUrl =
      'http://localhost:3000/api'; // Ajustar a tu configuración local

  // Endpoints de autenticación
  static const String loginUrl = '$baseUrl/auth/login';
  static const String logoutUrl = '$baseUrl/auth/logout';
  static const String validateTokenUrl = '$baseUrl/auth/validate';

  // Endpoints de producto
  static const String productsUrl = '$baseUrl/products';
  static const String searchProductUrl = '$baseUrl/products/search';

  // Endpoints de ubicación
  static const String locationsUrl = '$baseUrl/locations';
  static const String updateLocationUrl = '$baseUrl/products/location';

  // Endpoints de etiquetas
  static const String labelsUrl = '$baseUrl/labels';

  // Endpoints de entrada (picking)
  static const String entryScansUrl = '$baseUrl/entry/scans';
  static const String entryDeliveryNotesUrl = '$baseUrl/entry/delivery-notes';

  // Endpoints de recogida (salida)
  static const String loadOrdersUrl = '$baseUrl/picking/load-orders';
  static const String pickingScansUrl = '$baseUrl/picking/scans';
  static const String customerDeliveryNotesUrl =
      '$baseUrl/picking/delivery-notes';

  // Configuración de WebSocket
  static const String wsUrl = 'ws://192.168.1.33:3000/ws';
}
