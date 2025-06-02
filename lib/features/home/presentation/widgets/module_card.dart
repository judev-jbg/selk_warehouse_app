// lib/features/home/presentation/widgets/module_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ModuleCard extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final VoidCallback? onTap;

  const ModuleCard({
    Key? key,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isEnabled = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isEnabled ? 3 : 1,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isEnabled ? null : AppColors.disabled.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      (isEnabled ? color : AppColors.disabled).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isEnabled ? color : AppColors.disabled,
                ),
              ),

              const SizedBox(height: 12),

              // Nombre del módulo
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isEnabled
                          ? AppColors.textPrimary
                          : AppColors.disabled,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Descripción
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isEnabled
                          ? AppColors.textSecondary
                          : AppColors.disabled,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (!isEnabled) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.disabled.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Sin acceso',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.disabled,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
