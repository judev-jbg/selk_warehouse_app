import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class LoginParams {
  final String username;
  final String password;

  LoginParams({required this.username, required this.password});
}

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.username, params.password);
  }
}
