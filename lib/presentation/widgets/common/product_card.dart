import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool showEditIcons;
  final Function(String, String)? onFieldUpdate;

  const ProductCard({
    Key? key,
    required this.product,
    this.showEditIcons = false,
    this.onFieldUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.description,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(product.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(product.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoItem('Referencia', product.reference),
            _buildInfoItem('Código de barras', product.barcode),
            _buildEditableInfoItem(
              'Localización',
              product.location,
              'location',
              showEditIcons && onFieldUpdate != null,
              context,
            ),
            _buildEditableInfoItem(
              'Stock',
              '${product.stock} ${product.unit}',
              'stock',
              showEditIcons && onFieldUpdate != null,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEditableInfoItem(
    String label,
    String value,
    String field,
    bool isEditable,
    BuildContext context,
  ) {
    if (!isEditable) {
      return _buildInfoItem(label, value);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primary, size: 20),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {
              _showEditDialog(context, label, value, field, onFieldUpdate!);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String label,
    String currentValue,
    String field,
    Function(String, String) onUpdate,
  ) {
    // Extraer el valor numérico para el campo stock
    final String initialValue =
        field == 'stock' ? currentValue.split(' ')[0] : currentValue;

    final TextEditingController controller = TextEditingController(
      text: initialValue,
    );

    // Usamos StatefulBuilder para manejar el estado dentro del diálogo
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              // Variable para controlar si el valor ha cambiado
              bool hasChanged = controller.text != initialValue;

              // Listener para detectar cambios en el valor
              controller.addListener(() {
                setState(() {
                  hasChanged = controller.text != initialValue;
                });
              });

              return AlertDialog(
                title: Text('Editar $label'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(),
                    helperText: 'Valor actual: $initialValue',
                  ),
                  autofocus: true,
                  keyboardType:
                      field == 'stock'
                          ? TextInputType.number
                          : TextInputType.text,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed:
                        hasChanged
                            ? () {
                              Navigator.pop(context);
                              onUpdate(field, controller.text);
                            }
                            : null, // Deshabilitar cuando no hay cambios
                    child: Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
        return AppColors.success;
      case 'inactivo':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _getStatusText(String status) {
    return status.toUpperCase();
  }
}
