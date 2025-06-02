// lib/features/auth/presentation/bloc/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {}

/// Estado de carga
class AuthLoading extends AuthState {}

/// Usuario autenticado
class AuthAuthenticated extends AuthState {
  final User user;
  final String accessToken;

  const AuthAuthenticated({
    required this.user,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [user, accessToken];
}

/// Usuario no autenticado
class AuthUnauthenticated extends AuthState {}

/// Error de autenticación
class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Token refrescado
class AuthTokenRefreshed extends AuthState {
  final String newAccessToken;

  const AuthTokenRefreshed({required this.newAccessToken});

  @override
  List<Object?> get props => [newAccessToken];
}

/// Logout exitoso
class AuthLoggedOut extends AuthState {}

/// Verificando sesión existente
class AuthCheckingSession extends AuthState {}

/// Sesión expirada - necesita re-autenticación
class AuthSessionExpired extends AuthState {
  final String message;

  const AuthSessionExpired({
    this.message =
        'Su sesión ha expirado. Por favor, inicie sesión nuevamente.',
  });

  @override
  List<Object?> get props => [message];
}
