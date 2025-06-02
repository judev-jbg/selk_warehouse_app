// lib/features/auth/presentation/bloc/auth_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/login_request.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Iniciar sesión
class AuthLoginRequested extends AuthEvent {
  final LoginRequest loginRequest;

  const AuthLoginRequested({required this.loginRequest});

  @override
  List<Object?> get props => [loginRequest];
}

/// Cerrar sesión
class AuthLogoutRequested extends AuthEvent {}

/// Verificar sesión existente al iniciar la app
class AuthCheckSessionRequested extends AuthEvent {}

/// Refrescar token
class AuthRefreshTokenRequested extends AuthEvent {
  final String refreshToken;
  final String deviceId;

  const AuthRefreshTokenRequested({
    required this.refreshToken,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [refreshToken, deviceId];
}

/// Limpiar errores
class AuthClearError extends AuthEvent {}

/// Forzar logout (por expiración o error crítico)
class AuthForceLogout extends AuthEvent {
  final String reason;

  const AuthForceLogout({required this.reason});

  @override
  List<Object?> get props => [reason];
}

/// Verificar si el token necesita renovación
class AuthCheckTokenExpiration extends AuthEvent {}

/// Usuario autenticado desde caché
class AuthUserLoadedFromCache extends AuthEvent {
  final String accessToken;

  const AuthUserLoadedFromCache({required this.accessToken});

  @override
  List<Object?> get props => [accessToken];
}
