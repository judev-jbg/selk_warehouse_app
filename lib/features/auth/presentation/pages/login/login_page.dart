// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selk_warehouse_app/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:selk_warehouse_app/features/auth/presentation/bloc/auth/auth_state.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../shared/utils/device_info.dart';
import '../../../../../shared/utils/extensions.dart';
import '../../../../../shared/widgets/common/loading_overlay.dart';
import '../../../../../shared/widgets/common/error_widget.dart';
import '../../../domain/entities/login_request.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _initializeDeviceId();
  }

  Future<void> _initializeDeviceId() async {
    _deviceId = await DeviceInfoUtil.generateDeviceId();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is AuthAuthenticated) {
            // Navegar a la pantalla principal
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: LoadingOverlay(
          isLoading: _isLoading,
          message: 'Autenticando...',
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo y título
                    _buildHeader(),

                    const SizedBox(height: 60),

                    // Campos del formulario
                    _buildLoginForm(),

                    const SizedBox(height: 40),

                    // Botón de login
                    _buildLoginButton(),

                    const SizedBox(height: 20),

                    // Información adicional
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo placeholder (puedes reemplazar con tu logo)
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text(
              'SELK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Sistema de Gestión de Almacén',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          label: 'Usuario',
          hint: 'Ingrese su usuario',
          controller: _usernameController,
          isRequired: true,
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El usuario es requerido';
            }
            if (value.trim().length < 3) {
              return 'El usuario debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Contraseña',
          hint: 'Ingrese su contraseña',
          controller: _passwordController,
          isPassword: true,
          isRequired: true,
          prefixIcon: Icons.lock_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La contraseña es requerida';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return CustomButton(
      text: 'Iniciar Sesión',
      onPressed: _handleLogin,
      isLoading: _isLoading,
      icon: Icons.login,
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: AppColors.divider),
        const SizedBox(height: 16),
        Text(
          'Versión ${AppConstants.appVersion}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 8),
        if (_deviceId != null)
          Text(
            'Device ID: $_deviceId',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
              fontFamily: 'monospace',
            ),
          ),
      ],
    );
  }

  void _handleLogin() async {
    // Verificar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Verificar device ID
    if (_deviceId == null) {
      _deviceId = await DeviceInfoUtil.generateDeviceId();
      if (_deviceId == null) {
        _showErrorSnackBar('Error obteniendo información del dispositivo');
        return;
      }
    }

    // Crear request de login
    final loginRequest = LoginRequest(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      deviceIdentifier: _deviceId!,
    );

    // Enviar evento al BLoC
    context.read<AuthBloc>().add(
          AuthLoginRequested(loginRequest: loginRequest),
        );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
