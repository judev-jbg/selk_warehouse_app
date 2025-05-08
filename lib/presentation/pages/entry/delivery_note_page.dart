import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/supplier.dart';
import '../../../mocks/entry_mocks.dart' as em;
import '../../bloc/entry/delivery_note_bloc.dart';
import '../../bloc/entry/delivery_note_event.dart';
import '../../bloc/entry/delivery_note_state.dart';
import '../../widgets/common/loading_overlay.dart';

// Para pruebas
import 'package:dartz/dartz.dart' as dz;
import '../../../domain/entities/scan.dart';
import '../../../domain/entities/delivery_note.dart';
import '../../../domain/entities/product.dart';

class DeliveryNotePage extends StatelessWidget {
  const DeliveryNotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => DeliveryNoteBloc(
            getAllSuppliers: em.MockGetAllSuppliers(),
            generateDeliveryNote: em.MockGenerateDeliveryNote(),
          )..add(GetSuppliersEvent()),
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
  Supplier? _selectedSupplier;

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
                  _buildSupplierSelector(context, state),
                  SizedBox(height: 24),
                  TextField(
                    controller: _referenceController,
                    decoration: InputDecoration(
                      labelText: 'Referencia de albarán del proveedor',
                      hintText: 'Ingrese el número de albarán del proveedor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildProductList(context, state),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _canGenerateDeliveryNote(state)
                              ? () => _generateDeliveryNote(context)
                              : null,
                      child: Text('Generar Albarán'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
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

  Widget _buildSupplierSelector(BuildContext context, DeliveryNoteState state) {
    if (state is SuppliersLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccione un proveedor',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<Supplier>(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            value: _selectedSupplier,
            hint: Text('Seleccione un proveedor'),
            items:
                state.suppliers.map((supplier) {
                  return DropdownMenuItem(
                    value: supplier,
                    child: Text(supplier.name),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSupplier = value;
              });

              context.read<DeliveryNoteBloc>().add(
                SelectSupplierEvent(supplierId: value!.id),
              );
            },
          ),
        ],
      );
    }

    return Container();
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

  bool _canGenerateDeliveryNote(DeliveryNoteState state) {
    return state is ScansForDeliveryNoteLoaded &&
        state.scans.isNotEmpty &&
        _selectedSupplier != null &&
        _referenceController.text.isNotEmpty;
  }

  void _generateDeliveryNote(BuildContext context) {
    // Verificar que tenemos toda la información necesaria
    if (_selectedSupplier == null || _referenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, complete todos los campos'),
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

class GenerateDeliveryNoteParams {
  final String supplierReference;
  final List<String> scanIds;

  GenerateDeliveryNoteParams({
    required this.supplierReference,
    required this.scanIds,
  });
}

class Failure {
  final String message;

  Failure(this.message);
}
