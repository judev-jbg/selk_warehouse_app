// lib/features/auth/data/datasources/auth_remote_datasource.dart
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Iniciar sesión
  Future<LoginResponseModel> login(LoginRequestModel request);

  /// Refrescar token
  Future<String> refreshToken(String refreshToken, String deviceId);

  /// Cerrar sesión
  Future<void> logout();

  /// Obtener perfil del usuario
  Future<UserModel> getProfile();

  /// Verificar token
  Future<bool> verifyToken();

  /// Obtener logs de auditoría
  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.loginEndpoint,
        data: request.toJson(),
      );

      if (response['success'] == true && response['data'] != null) {
        return LoginResponseModel.fromJson(
            response['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          response['error'] ?? 'Error en el login',
          response['code'],
        );
      }
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado en login: $e');
    }
  }

  @override
  Future<String> refreshToken(String refreshToken, String deviceId) async {
    try {
      final response = await apiClient.post(
        ApiConstants.refreshTokenEndpoint,
        data: {
          'refresh_token': refreshToken,
          'device_identifier': deviceId,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['access_token'] as String;
      } else {
        throw ServerException(
          response['error'] ?? 'Error refrescando token',
          response['code'],
        );
      }
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado refrescando token: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await apiClient.post(ApiConstants.logoutEndpoint);

      if (response['success'] != true) {
        throw ServerException(
          response['error'] ?? 'Error en logout',
          response['code'],
        );
      }
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado en logout: $e');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get(ApiConstants.profileEndpoint);

      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          response['error'] ?? 'Error obteniendo perfil',
          response['code'],
        );
      }
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado obteniendo perfil: $e');
    }
  }

  @override
  Future<bool> verifyToken() async {
    try {
      final response = await apiClient.post(ApiConstants.verifyTokenEndpoint);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return data['valid'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      // Si hay error verificando el token, asumimos que es inválido
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAuditLogs({int limit = 50}) async {
    try {
      final response = await apiClient.get(
        ApiConstants.auditLogsEndpoint,
        queryParameters: {'limit': limit},
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw ServerException(
          response['error'] ?? 'Error obteniendo logs de auditoría',
          response['code'],
        );
      }
    } catch (e) {
      if (e is AuthException || e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado obteniendo logs: $e');
    }
  }
}
