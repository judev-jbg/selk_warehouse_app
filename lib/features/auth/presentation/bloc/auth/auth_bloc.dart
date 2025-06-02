// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../../core/usecases/usecase.dart'; // Solo este import para NoParams
import '../../../domain/usecases/get_cached_user.dart';
import '../../../domain/usecases/login_user.dart';
import '../../../domain/usecases/logout_user.dart';
import '../../../domain/usecases/refresh_token.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final RefreshToken refreshToken;
  final GetCachedUser getCachedUser;
  final Logger _logger = Logger();

  AuthBloc({
    required this.loginUser,
    required this.logoutUser,
    required this.refreshToken,
    required this.getCachedUser,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckSessionRequested>(_onCheckSessionRequested);
    on<AuthRefreshTokenRequested>(_onRefreshTokenRequested);
    on<AuthClearError>(_onClearError);
    on<AuthForceLogout>(_onForceLogout);
    on<AuthCheckTokenExpiration>(_onCheckTokenExpiration);
    on<AuthUserLoadedFromCache>(_onUserLoadedFromCache);
  }

  /// Manejar solicitud de login
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      _logger.i(
          'Iniciando proceso de login para usuario: ${event.loginRequest.username}');

      final result = await loginUser(LoginParams(request: event.loginRequest));

      result.fold(
        (failure) {
          _logger.e('Error en login: ${failure.message}');
          emit(AuthError(message: failure.message, code: failure.code));
        },
        (loginResponse) {
          _logger
              .i('Login exitoso para usuario: ${loginResponse.user.username}');
          emit(AuthAuthenticated(
            user: loginResponse.user,
            accessToken: loginResponse.accessToken,
          ));
        },
      );
    } catch (e) {
      _logger.e('Error inesperado en login: $e');
      emit(const AuthError(message: 'Error inesperado durante el login'));
    }
  }

  /// Manejar solicitud de logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      _logger.i('Iniciando proceso de logout');

      // CORREGIDO: usar const NoParams() en lugar de NoParams()
      final result = await logoutUser(NoParams());

      result.fold(
        (failure) {
          _logger.e('Error en logout: ${failure.message}');
          // Incluso si hay error, forzar logout local
          emit(AuthLoggedOut());
        },
        (_) {
          _logger.i('Logout exitoso');
          emit(AuthLoggedOut());
        },
      );
    } catch (e) {
      _logger.e('Error inesperado en logout: $e');
      // Forzar logout incluso si hay error
      emit(AuthLoggedOut());
    }
  }

  /// Verificar sesión existente
  Future<void> _onCheckSessionRequested(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthCheckingSession());

    try {
      _logger.i('Verificando sesión existente');

      // CORREGIDO: usar const NoParams() en lugar de NoParams()
      final result = await getCachedUser(NoParams());

      result.fold(
        (failure) {
          _logger.w('No hay sesión válida: ${failure.message}');
          emit(AuthUnauthenticated());
        },
        (user) {
          _logger.i('Sesión válida encontrada para usuario: ${user.username}');
          // TODO: Aquí deberíamos verificar si el token sigue siendo válido
          // Por ahora, asumimos que es válido si está en caché
          emit(AuthAuthenticated(
            user: user,
            accessToken: '', // Se cargará después
          ));
        },
      );
    } catch (e) {
      _logger.e('Error verificando sesión: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// Refrescar token
  Future<void> _onRefreshTokenRequested(
    AuthRefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _logger.i('Refrescando token de acceso');

      final result = await refreshToken(RefreshTokenParams(
        refreshToken: event.refreshToken,
        deviceId: event.deviceId,
      ));

      result.fold(
        (failure) {
          _logger.e('Error refrescando token: ${failure.message}');
          if (failure.code == '401') {
            // Token de refresh inválido - forzar logout
            emit(const AuthSessionExpired(
              message:
                  'Su sesión ha expirado. Por favor, inicie sesión nuevamente.',
            ));
          } else {
            emit(AuthError(message: failure.message, code: failure.code));
          }
        },
        (newAccessToken) {
          _logger.i('Token refrescado exitosamente');
          emit(AuthTokenRefreshed(newAccessToken: newAccessToken));
        },
      );
    } catch (e) {
      _logger.e('Error inesperado refrescando token: $e');
      emit(const AuthError(message: 'Error refrescando token'));
    }
  }

  /// Limpiar errores
  void _onClearError(
    AuthClearError event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }

  /// Forzar logout
  Future<void> _onForceLogout(
    AuthForceLogout event,
    Emitter<AuthState> emit,
  ) async {
    _logger.w('Forzando logout: ${event.reason}');

    try {
      await logoutUser(NoParams());
    } catch (e) {
      _logger.e('Error en logout forzado: $e');
    }

    emit(AuthLoggedOut());
  }

  /// Verificar expiración del token
  void _onCheckTokenExpiration(
    AuthCheckTokenExpiration event,
    Emitter<AuthState> emit,
  ) {
    // TODO: Implementar lógica para verificar si el token está próximo a expirar
    // Por ahora, no hace nada - se implementará cuando tengamos más detalles
  }

  /// Usuario cargado desde caché
  void _onUserLoadedFromCache(
    AuthUserLoadedFromCache event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await getCachedUser(NoParams());

      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (user) => emit(AuthAuthenticated(
          user: user,
          accessToken: event.accessToken,
        )),
      );
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
