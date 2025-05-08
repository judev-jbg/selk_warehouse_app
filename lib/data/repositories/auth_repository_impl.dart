import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasourse.dart';
import '../datasources/remote/auth_remote_datasourse.dart';
import '../models/user_model.dart';

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
  Future<Either<Failure, User>> login(String username, String password) async {
    // Implementación temporal para pruebas
    try {
      if (await networkInfo.isConnected) {
        try {
          final userModel = await remoteDataSource.login(username, password);
          await localDataSource.cacheUser(userModel);
          return Right(userModel);
        } on ServerException catch (e) {
          return Left(ServerFailure(e.message));
        }
      } else {
        return Left(NetworkFailure('No hay conexión a internet'));
      }
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    // Implementación temporal
    return Left(AuthFailure('No hay sesión activa'));
  }
}
