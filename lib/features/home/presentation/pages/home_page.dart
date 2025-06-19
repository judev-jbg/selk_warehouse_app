// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/utils/extensions.dart';
import '../../../auth/domain/entities/user.dart';
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
          title: 'SELK',
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
                      'Menú principal',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),

                    const SizedBox(height: 16),

                    // Módulos
                    _buildModulesGrid(context, state.user),

                    const SizedBox(height: 24),
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

  Widget _buildModulesGrid(BuildContext context, User user) {
    final modules = [
      {
        'name': 'Colocación',
        'description': 'Ubicación de productos',
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
              ? () => _navigateToModule(context, module['name'] as String)
              : null,
        );
      },
    );
  }

  void _navigateToModule(BuildContext context, String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'colocación':
        Navigator.of(context).pushNamed('/colocacion');
        break;
      case 'entrada':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Módulo $moduleName en desarrollo'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        break;
      case 'recogida':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Módulo $moduleName en desarrollo'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Módulo $moduleName en desarrollo'),
            backgroundColor: AppColors.info,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        break;
    }
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
