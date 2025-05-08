import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/common/params.dart'; // Importar de aquí
import '../../../domain/usecases/auth/login_user.dart';
import '../../../domain/usecases/auth/logout_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final loginUser;
  final logoutUser;

  AuthBloc({required this.loginUser, required this.logoutUser})
    : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Llamada al caso de uso de login
      final result = await loginUser(
        LoginParams(username: event.username, password: event.password),
      );

      // Manejo del resultado (success/failure)
      result.fold(
        (failure) =>
            emit(AuthError('Error de autenticación: ${failure.message}')),
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (e) {
      emit(AuthError('Error inesperado en la pp: $e'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Llamada al caso de uso de logout
      final result = await logoutUser(NoParams());

      // Manejo del resultado (success/failure)
      result.fold(
        (failure) =>
            emit(AuthError('Error al cerrar sesión: ${failure.message}')),
        (_) => emit(AuthUnauthenticated()),
      );
    } catch (e) {
      emit(AuthError('Error inesperado: $e'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Aquí verificaríamos si hay un token almacenado y si es válido
    // Por simplicidad, ahora solo emitimos no autenticado
    emit(AuthUnauthenticated());
  }
}

// Clases auxiliares para que compile
class LoginParams {
  final String username;
  final String password;
  LoginParams({required this.username, required this.password});
}

class NoParams {}
