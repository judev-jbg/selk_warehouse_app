import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/label.dart';
import '../../../domain/entities/product.dart';
import '../../bloc/placement/labels_bloc.dart';
import '../../bloc/placement/labels_event.dart';
import '../../bloc/placement/labels_state.dart';

// Clases Mock para pruebas
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/placement/get_labels.dart';
import '../../../domain/usecases/placement/print_labels.dart';
import '../../../domain/usecases/placement/delete_label.dart';
import '../../../domain/repositories/placement_repository.dart';

class LabelsPage extends StatelessWidget {
  const LabelsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Creamos un repositorio mock
    final mockRepository = MockPlacementRepository();

    // Creamos los casos de uso utilizando el repositorio mock
    return BlocProvider(
      create:
          (context) => LabelsBloc(
            getLabels: GetLabels(mockRepository),
            printLabels: PrintLabels(mockRepository),
            deleteLabel: DeleteLabel(mockRepository),
          )..add(GetLabelsEvent()),
      child: _LabelsPageContent(),
    );
  }
}

class _LabelsPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etiquetas Pendientes'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<LabelsBloc, LabelsState>(
        listener: (context, state) {
          if (state is LabelsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is LabelsPrintSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Etiquetas enviadas a imprimir correctamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is LabelDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Etiqueta eliminada correctamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LabelsLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is LabelsLoaded) {
            return _buildLabelsList(context, state.labels);
          } else if (state is LabelsEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.label_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay etiquetas pendientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Las etiquetas se generan al modificar la ubicación de un producto',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Container();
        },
      ),
      bottomNavigationBar: BlocBuilder<LabelsBloc, LabelsState>(
        builder: (context, state) {
          if (state is LabelsLoaded &&
              state.labels.any((label) => label.selected)) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  final selectedLabelIds =
                      state.labels
                          .where((label) => label.selected)
                          .map((label) => label.id)
                          .toList();

                  context.read<LabelsBloc>().add(
                    PrintLabelsEvent(labelIds: selectedLabelIds),
                  );
                },
                child: Text('Imprimir Etiquetas Seleccionadas'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            );
          }
          return SizedBox(height: 0);
        },
      ),
    );
  }

  Widget _buildLabelsList(BuildContext context, List<Label> labels) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: labels.length,
      itemBuilder: (context, index) {
        final label = labels[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: CheckboxListTile(
            title: Text(
              label.product.description,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ref: ${label.product.reference}'),
                Text('Ubicación: ${label.product.location}'),
                Text('Generada: ${label.createdAt}'),
              ],
            ),
            secondary: IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () {
                _showDeleteConfirmDialog(context, label);
              },
            ),
            value: label.selected,
            onChanged: (value) {
              context.read<LabelsBloc>().add(
                ToggleLabelSelectionEvent(
                  labelId: label.id,
                  selected: value ?? false,
                ),
              );
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Label label) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Eliminar Etiqueta'),
            content: Text(
              '¿Está seguro que desea eliminar la etiqueta para "${label.product.description}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  BlocProvider.of<LabelsBloc>(
                    context,
                  ).add(DeleteLabelEvent(labelId: label.id));
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

// Implementación del repositorio mock
class MockPlacementRepository implements PlacementRepository {
  final List<Label> _labels = [
    Label(
      id: '1',
      product: Product(
        id: '1',
        reference: '5808  493256E',
        description: 'Tornillo hexagonal M8x40',
        barcode: '7898422746759',
        location: 'A102',
        stock: 120.0,
        unit: 'unidades',
        status: 'Activo',
      ),
      createdAt: '2025-05-08 10:30:00',
    ),
    Label(
      id: '2',
      product: Product(
        id: '2',
        reference: '5810  493258E',
        description: 'Tornillo hexagonal M10x60',
        barcode: '7898422746760',
        location: 'A103',
        stock: 85.0,
        unit: 'unidades',
        status: 'Activo',
      ),
      createdAt: '2025-05-08 11:15:00',
    ),
  ];

  // Productos de ejemplo
  final Map<String, Product> _products = {
    '7898422746759': Product(
      id: '1',
      reference: '5808  493256E',
      description: 'Tornillo hexagonal M8x40',
      barcode: '7898422746759',
      location: 'A102',
      stock: 120.0,
      unit: 'unidades',
      status: 'Activo',
    ),
    '7898422746760': Product(
      id: '2',
      reference: '5810  493258E',
      description: 'Tornillo hexagonal M10x60',
      barcode: '7898422746760',
      location: 'A103',
      stock: 85.0,
      unit: 'unidades',
      status: 'Activo',
    ),
    '7898422746761': Product(
      id: '3',
      reference: '9999  503',
      description: 'Tornillo especial zincado',
      barcode: '7898422746761',
      location: 'B201',
      stock: 42.0,
      unit: 'unidades',
      status: 'Activo',
    ),
  };

  @override
  Future<Either<Failure, Product>> searchProductByBarcode(
    String barcode,
  ) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia

    final product = _products[barcode];
    if (product != null) {
      return Right(product);
    } else {
      return Left(
        NotFoundFailure(
          'No se encontró ningún producto con el código $barcode',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Product>> updateProductLocation(
    String productId,
    String newLocation,
  ) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia

    try {
      final product = _products.values.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(location: newLocation);

      // Actualizar el producto en el mapa
      _products[updatedProduct.barcode] = updatedProduct;

      // Crear una etiqueta para este producto
      _labels.add(
        Label(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          product: updatedProduct,
          createdAt: DateTime.now().toString(),
        ),
      );

      return Right(updatedProduct);
    } catch (e) {
      return Left(
        NotFoundFailure('No se encontró ningún producto con el ID $productId'),
      );
    }
  }

  @override
  Future<Either<Failure, Product>> updateProductStock(
    String productId,
    double newStock,
  ) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia

    try {
      final product = _products.values.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(stock: newStock);

      // Actualizar el producto en el mapa
      _products[updatedProduct.barcode] = updatedProduct;

      return Right(updatedProduct);
    } catch (e) {
      return Left(
        NotFoundFailure('No se encontró ningún producto con el ID $productId'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Label>>> getPendingLabels() async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia
    return Right(_labels);
  }

  @override
  Future<Either<Failure, List<Label>>> printLabels(
    List<String> labelIds,
  ) async {
    await Future.delayed(Duration(seconds: 2)); // Simular impresión

    final printedLabels = <Label>[];

    for (var id in labelIds) {
      final index = _labels.indexWhere((label) => label.id == id);
      if (index != -1) {
        final label = _labels[index];
        final updatedLabel = label.copyWith(printed: true);
        _labels[index] = updatedLabel;
        printedLabels.add(updatedLabel);
      }
    }

    return Right(printedLabels);
  }

  @override
  Future<Either<Failure, void>> deleteLabel(String labelId) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia

    _labels.removeWhere((label) => label.id == labelId);

    return Right(null);
  }
}

class NotFoundFailure extends Failure {
  NotFoundFailure(String message) : super(message);
}

class NoParams {}

class PrintLabelsParams {
  final List<String> labelIds;
  PrintLabelsParams({required this.labelIds});
}

class DeleteLabelParams {
  final String labelId;
  DeleteLabelParams({required this.labelId});
}
