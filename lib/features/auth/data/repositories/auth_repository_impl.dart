// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/entities/login_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, LoginResponse>> login(LoginRequest request) async {
    try {
      // Verificar conectividad
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Sin conexión a internet'));
      }

      // Convertir a modelo y enviar request
      final requestModel = LoginRequestModel.fromEntity(request);
      final loginResponse = await remoteDataSource.login(requestModel);

      // Guardar datos localmente
      await localDataSource.saveLoginData(loginResponse);

      // Crear log de auditoría local
      await localDataSource.saveAuditLog(
        userId: loginResponse.user.id,
        action: 'login',
        deviceId: request.deviceIdentifier,
        metadata: {
          'login_method': 'credentials',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return Right(loginResponse);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Error inesperado durante el login: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(
      String refreshToken, String deviceId) async {
    try {
      // Verificar conectividad
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Sin conexión a internet'));
      }

      // Refrescar token
      final newAccessToken =
          await remoteDataSource.refreshToken(refreshToken, deviceId);

      // Guardar nuevo token localmente
      await localDataSource.saveAccessToken(newAccessToken);

      return Right(newAccessToken);
    } on AuthException catch (e) {
      // Si el refresh token es inválido, limpiar datos locales
      await localDataSource.clearAllData();
      return Left(AuthFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Error inesperado refrescando token: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Intentar logout remoto si hay conexión
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout();
        } catch (e) {
          // Si falla el logout remoto, continuar con logout local
          // El servidor limpiará la sesión eventualmente
        }
      }

      // Crear log de auditoría antes de limpiar datos
      try {
        final user = await localDataSource.getCachedUser();
        final deviceId = await localDataSource.getDeviceId();

        if (deviceId != null) {
          await localDataSource.saveAuditLog(
            userId: user.id,
            action: 'logout',
            deviceId: deviceId,
            metadata: {
              'logout_type': 'manual',
              'timestamp': DateTime.now().toIso8601String(),
            },
          );
        }
      } catch (e) {
        // Si no se puede crear el log, continuar con logout
      }

      // Limpiar datos locales
      await localDataSource.clearAllData();

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Error inesperado durante logout: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, e.code));
    } catch (e) {
      return Left(CacheFailure('Error obteniendo usuario desde caché: $e'));
    }
  }

  @override
  Future<bool> hasValidSession() async {
    try {
      return await localDataSource.hasValidSession();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> clearSession() async {
    try {
      await localDataSource.clearAllData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, e.code));
    } catch (e) {
      return Left(CacheFailure('Error limpiando sesión: $e'));
    }
  }

  @override
  Future<bool> shouldRefreshToken() async {
    try {
      // Verificar si el token necesita renovación
      // Esto se puede implementar verificando la fecha de expiración
      // Por ahora, verificamos con el servidor si hay conexión
      if (await networkInfo.isConnected) {
        return !(await remoteDataSource.verifyToken());
      }
      return false;
    } catch (e) {
      return true; // Si hay error, asumir que necesita refresh
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAuditLogs(
      {int limit = 50}) async {
    try {
      List<Map<String, dynamic>> logs = [];

      // Intentar obtener logs remotos si hay conexión
      if (await networkInfo.isConnected) {
        try {
          logs = await remoteDataSource.getAuditLogs(limit: limit);
        } catch (e) {
          // Si falla, continuar con logs locales
        }
      }

      // Si no hay logs remotos, obtener logs locales
      if (logs.isEmpty) {
        logs = await localDataSource.getPendingAuditLogs();
      }

      return Right(logs);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Error obteniendo logs de auditoría: $e'));
    }
  }
}
