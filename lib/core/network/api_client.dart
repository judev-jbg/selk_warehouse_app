// lib/core/network/api_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class ApiClient {
  final Dio _dio;
  final Logger _logger;
  String? _accessToken;
  String? _deviceId;

  ApiClient({
    Dio? dio,
    Logger? logger,
  })  : _dio = dio ?? Dio(),
        _logger = logger ?? Logger() {
    _setupInterceptors();
  }

  /// Configurar interceptores de Dio
  void _setupInterceptors() {
    // Interceptor para requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Agregar headers por defecto
          options.headers[ApiConstants.contentTypeHeader] =
              ApiConstants.contentTypeJson;
          options.headers[ApiConstants.userAgentHeader] =
              ApiConstants.userAgentValue;

          // Agregar token de autorización si existe
          if (_accessToken != null) {
            options.headers[ApiConstants.authorizationHeader] =
                'Bearer $_accessToken';
          }

          // Agregar device ID si existe
          if (_deviceId != null) {
            options.headers[ApiConstants.deviceIdHeader] = _deviceId;
          }

          _logger.d('🚀 REQUEST: ${options.method} ${options.uri}');
          _logger.d('📋 Headers: ${options.headers}');
          if (options.data != null) {
            _logger.d('📦 Body: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
              '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          _logger.d('📦 Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ ERROR: ${error.requestOptions.uri}');
          _logger.e('📦 Error: ${error.message}');
          _logger.e('📦 Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    // Configuración base
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      sendTimeout: AppConstants.requestTimeout,
    );
  }

  /// Establecer token de acceso
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Establecer device ID
  void setDeviceId(String deviceId) {
    _deviceId = deviceId;
  }

  /// Limpiar credenciales
  void clearCredentials() {
    _accessToken = null;
    _deviceId = null;
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Manejar respuesta exitosa
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {'data': response.data};
      }
    } else {
      throw ServerException(
        'Error del servidor: ${response.statusMessage}',
        response.statusCode.toString(),
      );
    }
  }

  /// Manejar errores
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException('Tiempo de conexión agotado');

        case DioExceptionType.connectionError:
          return const NetworkException('Error de conexión. Verifique su red.');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['error'] ??
              error.response?.statusMessage ??
              'Error del servidor';

          switch (statusCode) {
            case 401:
              return AuthException(message, statusCode.toString());
            case 403:
              return AuthException(
                  'Sin permisos suficientes', statusCode.toString());
            case 404:
              return ServerException(
                  'Recurso no encontrado', statusCode.toString());
            case 500:
              return ServerException(
                  'Error interno del servidor', statusCode.toString());
            default:
              return ServerException(message, statusCode.toString());
          }

        case DioExceptionType.cancel:
          return const NetworkException('Solicitud cancelada');

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return const NetworkException('Sin conexión a internet');
          }
          return const NetworkException('Error de red desconocido');

        default:
          return NetworkException('Error de red: ${error.message}');
      }
    }

    return ServerException('Error inesperado: $error');
  }
}
