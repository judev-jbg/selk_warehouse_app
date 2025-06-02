// lib/features/auth/domain/usecases/login_user.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/login_request.dart';
import '../entities/login_response.dart';
import '../repositories/auth_repository.dart';

class LoginUser implements UseCase<LoginResponse, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, LoginResponse>> call(LoginParams params) async {
    return await repository.login(params.request);
  }
}

class LoginParams {
  final LoginRequest request;

  LoginParams({required this.request});
}
