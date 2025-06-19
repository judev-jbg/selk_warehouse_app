// lib/features/colocacion/presentation/widgets/product_result_card.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/product_search_result.dart';
import '../../domain/entities/product.dart';
import 'editable_field.dart';

class ProductResultCard extends StatelessWidget {
  final ProductSearchResult searchResult;
  final Function(int productId, String newLocation) onLocationUpdate;
  final Function(int productId, double newStock) onStockUpdate;

  const ProductResultCard({
    Key? key,
    required this.searchResult,
    required this.onLocationUpdate,
    required this.onStockUpdate,
  }) : super(key: key);

  Product get product => searchResult.product!;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header con información de búsqueda
          _buildSearchHeader(context),

          const SizedBox(height: 16),

          // Card principal con información del producto
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del producto
                  _buildProductHeader(context),

                  const SizedBox(height: 20),

                  // Información básica (solo lectura)
                  _buildBasicInfo(context),

                  const SizedBox(height: 24),

                  // Campos editables
                  _buildEditableFields(context),

                  const SizedBox(height: 16),

                  // Estado del producto
                  _buildProductStatus(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: searchResult.cached
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: searchResult.cached
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            searchResult.cached ? Icons.cached : Icons.cloud_done,
            color: searchResult.cached ? AppColors.warning : AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              searchResult.cached
                  ? 'Resultado desde caché'
                  : 'Resultado actualizado',
              style: TextStyle(
                color:
                    searchResult.cached ? AppColors.warning : AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${searchResult.searchTime}ms',
            style: TextStyle(
              color:
                  searchResult.cached ? AppColors.warning : AppColors.success,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producto encontrado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${product.id}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          context,
          'Descripción',
          product.name,
          Icons.description,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          'Referencia',
          product.defaultCode.isNotEmpty
              ? product.defaultCode
              : 'Sin referencia',
          Icons.tag,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          'Código de barras',
          product.barcode,
          Icons.qr_code,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableFields(BuildContext context) {
    return Column(
      children: [
        // Campo de localización editable
        EditableField(
          label: 'Localización',
          value: product.displayLocation,
          icon: Icons.place,
          isRequired: false,
          placeholder: 'Ej: A105',
          keyboardType: TextInputType.text,
          validator: _validateLocation,
          onSave: (newValue) {
            if (newValue.trim() != product.location?.trim()) {
              onLocationUpdate(product.id, newValue.trim());
            }
          },
        ),

        const SizedBox(height: 16),

        // Campo de stock editable
        EditableField(
          label: 'Stock',
          value: product.formattedStock,
          icon: Icons.inventory,
          isRequired: false,
          placeholder: 'Ej: 25.5',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _validateStock,
          onSave: (newValue) {
            final newStock = double.tryParse(newValue.trim());
            if (newStock != null && newStock != product.qtyAvailable) {
              onStockUpdate(product.id, newStock);
            }
          },
        ),
      ],
    );
  }

  Widget _buildProductStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: product.active
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: product.active
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            product.active ? Icons.check_circle : Icons.cancel,
            color: product.active ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Estado: ${product.statusText}',
            style: TextStyle(
              color: product.active ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            product.uomName,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String? _validateLocation(String value) {
    if (value.trim().isEmpty) return null; // La localización es opcional

    // Validar formato: [A-Z][0-9][0-5]
    final pattern = RegExp(r'^[A-Z][0-9]{2}[0-5]$');
    if (!pattern.hasMatch(value.trim().toUpperCase())) {
      return 'Formato inválido. Use: [A-Z][00-99][0-5] (ej: A105)';
    }

    return null;
  }

  String? _validateStock(String value) {
    if (value.trim().isEmpty) return 'Stock requerido';

    final stock = double.tryParse(value.trim());
    if (stock == null) {
      return 'Ingrese un número válido';
    }

    if (stock < 0) {
      return 'El stock no puede ser negativo';
    }

    if (stock > 999999.99) {
      return 'Stock muy alto (máximo: 999,999.99)';
    }

    // Verificar máximo 2 decimales
    final parts = value.trim().split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Máximo 2 decimales permitidos';
    }

    return null;
  }
}
