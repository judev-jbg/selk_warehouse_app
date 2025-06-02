import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cliente API que maneja las peticiones HTTP a la API
class ApiClient {
  final Dio _dio;
  final SharedPreferences _preferences;

  ApiClient(this._dio, this._preferences) {
    _setupDio();
  }

  /// Configura el cliente Dio con interceptores y configuración base
  void _setupDio() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    // Interceptor para agregar token de autenticación
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _preferences.getString("");
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Reintento de petición en caso de error 401 (token expirado)
          if (error.response?.statusCode == 401) {
            // Aquí podríamos implementar el refresh token
            // Por ahora solo regresamos el error
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Getter para acceder al cliente Dio configurado
  Dio get dio => _dio;
}
