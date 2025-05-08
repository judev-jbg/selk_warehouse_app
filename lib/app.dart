import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selk_warehouse_app/injection_container.dart';
import 'core/themes/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/login/login_page.dart';
import 'main.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
      ],
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
