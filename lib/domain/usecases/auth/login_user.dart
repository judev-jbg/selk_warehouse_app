import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../common/params.dart'; // Importar de aquí

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.username, params.password);
  }
}
