// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/login_request.dart';
import '../entities/login_response.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Iniciar sesión con credenciales
  Future<Either<Failure, LoginResponse>> login(LoginRequest request);

  /// Refrescar token de acceso
  Future<Either<Failure, String>> refreshToken(
      String refreshToken, String deviceId);

  /// Cerrar sesión
  Future<Either<Failure, void>> logout();

  /// Obtener usuario desde caché
  Future<Either<Failure, User>> getCachedUser();

  /// Verificar si hay sesión válida
  Future<bool> hasValidSession();

  /// Limpiar datos de sesión
  Future<Either<Failure, void>> clearSession();

  /// Verificar si el token necesita renovación
  Future<bool> shouldRefreshToken();

  /// Obtener logs de auditoría del usuario
  Future<Either<Failure, List<Map<String, dynamic>>>> getAuditLogs(
      {int limit = 50});
}
