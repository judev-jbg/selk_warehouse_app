// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selk_warehouse_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:selk_warehouse_app/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/common/custom_app_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/module_card.dart';
import '../widgets/user_info_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut || state is AuthSessionExpired) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'SELK Warehouse',
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Cerrar Sesión',
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Información del usuario
                    UserInfoCard(user: state.user),

                    const SizedBox(height: 24),

                    // Título de módulos
                    Text(
                      'Módulos Disponibles',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 16),

                    // Módulos
                    _buildModulesGrid(context, state.user),

                    const SizedBox(height: 24),

                    // Información adicional
                    _buildInfoSection(context),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModulesGrid(BuildContext context, user) {
    final modules = [
      {
        'name': 'Colocación',
        'description': 'Gestión de ubicación de productos',
        'icon': Icons.place,
        'color': AppColors.colocacionColor,
        'route': '/colocacion',
        'permission': 'colocacion',
      },
      {
        'name': 'Entrada',
        'description': 'Recepción de mercancía',
        'icon': Icons.input,
        'color': AppColors.entradaColor,
        'route': '/entrada',
        'permission': 'entrada',
      },
      {
        'name': 'Recogida',
        'description': 'Preparación de pedidos',
        'icon': Icons.output,
        'color': AppColors.recogidaColor,
        'route': '/recogida',
        'permission': 'recogida',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        final hasPermission = user.canRead(module['permission'] as String);

        return ModuleCard(
          name: module['name'] as String,
          description: module['description'] as String,
          icon: module['icon'] as IconData,
          color: module['color'] as Color,
          isEnabled: hasPermission,
          onTap: hasPermission
              ? () => _navigateToModule(context, module['route'] as String)
              : null,
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Las sesiones se cierran automáticamente a las 16:00 horas\n'
              '• Mantenga activa la aplicación durante su jornada laboral\n'
              '• Los datos se sincronizan automáticamente con el servidor\n'
              '• En caso de problemas, contacte al administrador del sistema',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToModule(BuildContext context, String route) {
    // Por ahora, mostrar un mensaje de que el módulo está en desarrollo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Módulo $route en desarrollo'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Está seguro de que desea cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
