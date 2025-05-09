import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selk_warehouse_app/domain/usecases/entry/generate_delivery_note.dart';
import 'package:selk_warehouse_app/domain/usecases/entry/get_suppliers.dart';
import 'package:selk_warehouse_app/injection_container.dart';
import '../../../core/themes/app_colors.dart';
import '../../bloc/entry/delivery_note_bloc.dart';
import '../../bloc/entry/delivery_note_event.dart';
import '../../bloc/entry/delivery_note_state.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../mocks/entry_mocks.dart';

class DeliveryNotePage extends StatelessWidget {
  const DeliveryNotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Crear una nueva instancia del bloc con mocks concretos
    final deliveryNoteBloc = DeliveryNoteBloc(
      getAllSuppliers: MockGetAllSuppliers(), // Instancia directa del mock
      generateDeliveryNote:
          MockGenerateDeliveryNote(), // Instancia directa del mock
    );

    // Añadir el evento inicial
    deliveryNoteBloc.add(GetSuppliersEvent());

    return BlocProvider<DeliveryNoteBloc>.value(
      value: deliveryNoteBloc, // Usar el bloc ya creado
      child: _DeliveryNotePageContent(),
    );
  }
}

class _DeliveryNotePageContent extends StatefulWidget {
  @override
  _DeliveryNotePageContentState createState() =>
      _DeliveryNotePageContentState();
}

class _DeliveryNotePageContentState extends State<_DeliveryNotePageContent> {
  final _referenceController = TextEditingController();

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar Albarán'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
      ),
      body: BlocConsumer<DeliveryNoteBloc, DeliveryNoteState>(
        listener: (context, state) {
          if (state is DeliveryNoteError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is DeliveryNoteGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Albarán generado correctamente'),
                backgroundColor: AppColors.success,
              ),
            );

            // Regresar a la pantalla de entrada
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is DeliveryNoteLoading,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingrese el albarán del proveedor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _referenceController,
                    decoration: InputDecoration(
                      labelText: 'Albarán del proveedor',
                      hintText: 'Ingrese el número de albarán del proveedor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildProductList(context, state),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _referenceController,
                      builder: (context, value, child) {
                        return ElevatedButton(
                          onPressed:
                              value.text.isEmpty
                                  ? null
                                  : () => _generateDeliveryNote(context),
                          child: Text('Generar Albarán'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(BuildContext context, DeliveryNoteState state) {
    if (state is ScansForDeliveryNoteLoaded && state.scans.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos escaneados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: state.scans.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final scan = state.scans[index];
                return ListTile(
                  title: Text(
                    scan.product.description,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Ref: ${scan.product.reference}'),
                  trailing: Text(
                    '${scan.quantity} ${scan.product.unit}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (state is ScansForDeliveryNoteLoaded && state.scans.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: AppColors.warning),
            SizedBox(height: 16),
            Text(
              'No hay productos escaneados para este proveedor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container();
  }

  void _generateDeliveryNote(BuildContext context) {
    if (_referenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingrese el albarán del proveedor'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Llamar al bloc para generar el albarán
    context.read<DeliveryNoteBloc>().add(
      GenerateDeliveryNoteEvent(supplierReference: _referenceController.text),
    );
  }
}
