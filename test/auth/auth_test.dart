import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:selk_warehouse_app/core/errors/failures.dart';
import 'package:selk_warehouse_app/domain/entities/user.dart';
import 'package:selk_warehouse_app/domain/usecases/auth/login_user.dart';
import 'package:selk_warehouse_app/domain/usecases/auth/logout_user.dart';
import 'package:selk_warehouse_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:selk_warehouse_app/presentation/bloc/auth/auth_event.dart';
import 'package:selk_warehouse_app/presentation/bloc/auth/auth_state.dart';
import 'package:mockito/annotations.dart';

import 'auth_test.mocks.dart';

@GenerateMocks([LoginUser, LogoutUser])
void main() {
  late AuthBloc authBloc;
  late MockLoginUser mockLoginUser;
  late MockLogoutUser mockLogoutUser;

  setUp(() {
    mockLoginUser = MockLoginUser();
    mockLogoutUser = MockLogoutUser();
    authBloc = AuthBloc(loginUser: mockLoginUser, logoutUser: mockLogoutUser);
  });

  tearDown(() {
    authBloc.close();
  });

  test('El estado inicial debe ser AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  group('LoginEvent', () {
    final tUsername = 'operario1';
    final tPassword = 'password123';
    final tUser = User(
      id: 1,
      username: tUsername,
      name: 'Operario 1',
      roles: ['operario'],
      token: 'test_token',
    );

    test(
      'Debe emitir [AuthLoading, AuthAuthenticated] cuando el login es exitoso',
      () {
        // Arrange
        when(mockLoginUser(any)).thenAnswer((_) async => Right(tUser));

        // Assert
        final expected = [AuthLoading(), AuthAuthenticated(tUser)];

        expectLater(authBloc.stream, emitsInOrder(expected));

        // Act
        authBloc.add(LoginEvent(username: tUsername, password: tPassword));
      },
    );

    test('Debe emitir [AuthLoading, AuthError] cuando el login falla', () {
      // Arrange
      when(
        mockLoginUser(any),
      ).thenAnswer((_) async => Left(AuthFailure('Credenciales inválidas')));

      // Assert
      final expected = [
        AuthLoading(),
        AuthError('Error de autenticación: Credenciales inválidas'),
      ];

      expectLater(authBloc.stream, emitsInOrder(expected));

      // Act
      authBloc.add(LoginEvent(username: tUsername, password: tPassword));
    });
  });

  group('LogoutEvent', () {
    test(
      'Debe emitir [AuthLoading, AuthUnauthenticated] cuando el logout es exitoso',
      () {
        // Arrange
        when(mockLogoutUser(any)).thenAnswer((_) async => Right(null));

        // Assert
        final expected = [AuthLoading(), AuthUnauthenticated()];

        expectLater(authBloc.stream, emitsInOrder(expected));

        // Act
        authBloc.add(LogoutEvent());
      },
    );

    test('Debe emitir [AuthLoading, AuthError] cuando el logout falla', () {
      // Arrange
      when(
        mockLogoutUser(any),
      ).thenAnswer((_) async => Left(ServerFailure('Error en el servidor')));

      // Assert
      final expected = [
        AuthLoading(),
        AuthError('Error al cerrar sesión: Error en el servidor'),
      ];

      expectLater(authBloc.stream, emitsInOrder(expected));

      // Act
      authBloc.add(LogoutEvent());
    });
  });
}
