import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Inicia sesión con las credenciales proporcionadas
  ///
  /// Retorna un [User] si la autenticación es exitosa
  /// o un [Failure] si ocurre un error
  Future<Either<Failure, User>> login(String username, String password);

  /// Cierra la sesión del usuario actual
  ///
  /// Retorna void si es exitoso o un [Failure] si ocurre un error
  Future<Either<Failure, void>> logout();

  /// Verifica si hay un usuario autenticado actualmente
  ///
  /// Retorna un [User] si hay un usuario autenticado
  /// o un [Failure] si no hay sesión o ocurre un error
  Future<Either<Failure, User>> checkAuthStatus();
}
