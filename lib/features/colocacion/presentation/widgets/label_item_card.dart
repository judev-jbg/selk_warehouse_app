// lib/features/colocacion/presentation/widgets/label_item_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/utils/extensions.dart';
import '../../domain/entities/label.dart';

class LabelItemCard extends StatelessWidget {
  final Label label;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const LabelItemCard({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            color: isSelected ? AppColors.primary.withOpacity(0.05) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con checkbox y estado
              Row(
                children: [
                  // Checkbox o icono de etiqueta
                  if (isSelectionMode)
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          isSelected ? AppColors.primary : AppColors.textHint,
                      size: 24,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.label,
                        color: _getStatusColor(),
                        size: 20,
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label.product.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${label.product.id} • ${label.product.defaultCode}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Badge de estado
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: _getStatusColor().withOpacity(0.3)),
                    ),
                    child: Text(
                      label.displayStatus,
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Información del producto y localización
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Código de barras
                    _buildInfoRow(
                      'Código de barras',
                      label.product.barcode,
                      Icons.qr_code,
                    ),

                    const SizedBox(height: 8),

                    // Localización
                    _buildInfoRow(
                      'Localización',
                      label.location,
                      Icons.place,
                      isHighlighted: true,
                    ),

                    const SizedBox(height: 8),

                    // Stock
                    _buildInfoRow(
                      'Stock',
                      '${label.product.formattedStock} ${label.product.uomName}',
                      Icons.inventory,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Footer con fechas
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Creada: ${label.createdAt.timeAgo}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                  ),
                  const Spacer(),
                  if (label.updatedAt != label.createdAt) ...[
                    Text(
                      'Actualizada: ${label.updatedAt.timeAgo}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textHint,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {bool isHighlighted = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: isHighlighted ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (label.status) {
      case 'pending':
        return AppColors.warning;
      case 'printed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }
}
