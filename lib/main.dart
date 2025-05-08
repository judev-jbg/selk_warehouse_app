import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/pages/login/login_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'domain/entities/user.dart';

// Reemplazo temporal de la inyección de dependencias
final authBloc = AuthBloc(
  loginUser: SimplifiedLoginUser(),
  logoutUser: SimplifiedLogoutUser(),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // No llamamos a init() por ahora
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (context) => authBloc)],
      child: MaterialApp(
        title: 'Selk Warehouse',
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return HomePage();
            }
            return LoginPage();
          },
        ),
      ),
    );
  }
}

// Clases simplificadas para pruebas
class SimplifiedLoginUser {
  Future<Either<Failure, User>> call(LoginParams params) async {
    // Simulamos una petición al backend
    await Future.delayed(Duration(seconds: 1));

    if (params.username == 'operario1' && params.password == 'password123') {
      return Right(
        User(
          id: 1,
          username: 'operario1',
          name: 'Operario 1',
          roles: ['operario'],
          token: 'token-de-prueba',
        ),
      );
    } else {
      return Left(AuthFailure('Credenciales inválidas'));
    }
  }
}

class SimplifiedLogoutUser {
  Future<Either<Failure, void>> call(NoParams params) async {
    await Future.delayed(Duration(seconds: 1));
    return Right(null);
  }
}

// Para que el código compile
class Either<L, R> {
  final L? left;
  final R? right;
  final bool isRight;

  Either._(this.left, this.right, this.isRight);

  factory Either.left(L value) => Either._(value, null, false);
  factory Either.right(R value) => Either._(null, value, true);

  R getOrElse(R Function() defaultValue) {
    return isRight ? right! : defaultValue();
  }

  bool get isLeft => !isRight;

  B fold<B>(B Function(L) ifLeft, B Function(R) ifRight) {
    return isRight ? ifRight(right!) : ifLeft(left!);
  }
}

class Right<L, R> extends Either<L, R> {
  Right(R value) : super._(null, value, true);
}

class Left<L, R> extends Either<L, R> {
  Left(L value) : super._(value, null, false);
}

class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}
