import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Llama al endpoint de login
  ///
  /// Retorna [UserModel] si la autenticación es exitosa
  /// Lanza [ServerException] si ocurre un error
  Future<UserModel> login(String username, String password);

  /// Llama al endpoint de logout
  ///
  /// Lanza [ServerException] si ocurre un error
  Future<void> logout();

  /// Valida si el token actual es válido
  ///
  /// Lanza [ServerException] si el token no es válido o hay error
  Future<void> validateToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await client.post(
        ApiConstants.loginUrl,
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error en la autenticación',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Error de conexión con el servidor',
      );
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await client.post(ApiConstants.logoutUrl);

      if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Error al cerrar sesión',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Error de conexión con el servidor',
      );
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<void> validateToken() async {
    try {
      final response = await client.get(ApiConstants.validateTokenUrl);

      if (response.statusCode != 200) {
        throw ServerException('Token inválido');
      }
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Error de conexión con el servidor',
      );
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }
}
