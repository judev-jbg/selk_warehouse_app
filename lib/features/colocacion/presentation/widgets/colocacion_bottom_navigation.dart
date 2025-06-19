import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class ColocacionBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const ColocacionBottomNavigation({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Inicio / Home
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Inicio',
                index: 0,
                onTap: () => _navigateToHome(context),
              ),

              // Colocación (actual)
              _buildNavItem(
                context,
                icon: Icons.place,
                label: 'Colocación',
                index: 1,
                onTap: () => _navigateToColocacion(context),
              ),

              // Etiquetas
              _buildNavItem(
                context,
                icon: Icons.label,
                label: 'Etiquetas',
                index: 2,
                onTap: () => _navigateToLabels(context),
              ),

              // Cerrar sesión
              _buildNavItem(
                context,
                icon: Icons.logout,
                label: 'Salir',
                index: 3,
                onTap: () => _showLogoutDialog(context),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isSelected = currentIndex == index;
    final color = isDestructive
        ? AppColors.error
        : isSelected
            ? AppColors.primary
            : AppColors.textSecondary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected && !isDestructive
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: isSelected ? 26 : 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _navigateToLabels(BuildContext context) {
    Navigator.of(context).pushNamed('/colocacion/labels');
  }

  void _navigateToColocacion(BuildContext context) {
    Navigator.of(context).pushNamed('/colocacion');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Cerrar Sesión'),
            ],
          ),
          content: const Text(
            '¿Está seguro de que desea cerrar sesión?\n\nSe perderán los datos no sincronizados.',
          ),
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
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
