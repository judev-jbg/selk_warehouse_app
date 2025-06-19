// lib/features/colocacion/presentation/widgets/error_message_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ErrorMessageCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? backgroundColor;
  final Color? iconColor;

  const ErrorMessageCard({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.error.withOpacity(0.05);
    final iColor = iconColor ?? AppColors.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono grande
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: iColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Título
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: iColor,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Mensaje
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                  textAlign: TextAlign.center,
                ),

                if (actionText != null && onAction != null) ...[
                  const SizedBox(height: 24),

                  // Botón de acción
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAction,
                      icon: Icon(
                        _getActionIcon(),
                        size: 18,
                      ),
                      label: Text(actionText!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Consejo adicional
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.info,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getHelpText(),
                          style: TextStyle(
                            color: AppColors.info,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getActionIcon() {
    switch (actionText?.toLowerCase()) {
      case 'reintentar':
        return Icons.refresh;
      case 'buscar otro':
        return Icons.search;
      case 'volver':
        return Icons.arrow_back;
      default:
        return Icons.touch_app;
    }
  }

  String _getHelpText() {
    if (title.toLowerCase().contains('no encontrado')) {
      return 'Verifique que el código sea correcto o que el producto esté registrado en el sistema';
    } else if (title.toLowerCase().contains('error')) {
      return 'Si el problema persiste, contacte al administrador del sistema';
    } else {
      return 'Asegúrese de que la PDA tenga conexión a internet';
    }
  }
}