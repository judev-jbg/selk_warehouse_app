import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_color.dart';
import '../../../domain/entities/scan.dart';
import '../../bloc/entry/scans_bloc.dart';
import '../../bloc/entry/scans_event.dart';
import '../../bloc/entry/scans_state.dart';
import 'delivery_note_page.dart';

class ScansPage extends StatelessWidget {
  const ScansPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ScansBloc(
            getScans: context.read(),
            updateScan: context.read(),
            deleteScan: context.read(),
          )..add(GetScansEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lecturas Registradas'),
          backgroundColor: AppColors.primary,
        ),
        body: BlocConsumer<ScansBloc, ScansState>(
          listener: (context, state) {
            if (state is ScansError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is ScanUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lectura actualizada correctamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is ScanDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lectura eliminada correctamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ScansLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ScansLoaded) {
              return _buildScansList(context, state.scans);
            } else if (state is ScansEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay lecturas registradas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Escanee productos en la pantalla de Entrada',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return Container();
          },
        ),
        bottomNavigationBar: BlocBuilder<ScansBloc, ScansState>(
          builder: (context, state) {
            if (state is ScansLoaded && state.scans.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DeliveryNotePage()),
                    );
                  },
                  child: Text('Generar Albarán'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              );
            }
            return SizedBox(height: 0);
          },
        ),
      ),
    );
  }

  Widget _buildScansList(BuildContext context, List<Scan> scans) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: scans.length,
      itemBuilder: (context, index) {
        final scan = scans[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              scan.product.description,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ref: ${scan.product.reference}'),
                Text('Cantidad: ${scan.quantity}'),
                if (scan.supplierId != null)
                  Text('Proveedor: ${scan.supplierId}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () {
                    _showEditDialog(context, scan);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.error),
                  onPressed: () {
                    _showDeleteDialog(context, scan);
                  },
                ),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Scan scan) {
    final TextEditingController controller = TextEditingController(
      text: scan.quantity.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Editar Cantidad'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.product.description,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ScansBloc>().add(
                    UpdateScanEvent(
                      scanId: scan.id,
                      newQuantity: double.tryParse(controller.text) ?? 0,
                    ),
                  );
                },
                child: Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, Scan scan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Eliminar Lectura'),
            content: Text('¿Está seguro que desea eliminar esta lectura?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ScansBloc>().add(
                    DeleteScanEvent(scanId: scan.id),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
