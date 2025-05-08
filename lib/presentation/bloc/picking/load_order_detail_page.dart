import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class LoadOrderDetailPage extends StatelessWidget {
  final String loadOrderId;

  const LoadOrderDetailPage({Key? key, required this.loadOrderId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Orden #${loadOrderId}'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2, size: 64, color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Detalle de Orden de Carga',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Esta funcionalidad estará disponible próximamente',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
