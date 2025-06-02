// lib/features/auth/domain/usecases/refresh_token.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RefreshToken implements UseCase<String, RefreshTokenParams> {
  final AuthRepository repository;

  RefreshToken(this.repository);

  @override
  Future<Either<Failure, String>> call(RefreshTokenParams params) async {
    return await repository.refreshToken(params.refreshToken, params.deviceId);
  }
}

class RefreshTokenParams {
  final String refreshToken;
  final String deviceId;

  RefreshTokenParams({
    required this.refreshToken,
    required this.deviceId,
  });
}
