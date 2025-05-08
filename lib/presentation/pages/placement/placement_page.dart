import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/usecases/placement/search_product.dart';
import '../../../domain/usecases/placement/update_location.dart';
import '../../../domain/usecases/placement/update_stock.dart';
import '../../bloc/placement/placement_bloc.dart';
import '../../bloc/placement/placement_event.dart';
import '../../bloc/placement/placement_state.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/loading_overlay.dart';
import 'labels_page.dart';

// Repositorio Mock para pruebas
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/label.dart';
import '../../../domain/repositories/placement_repository.dart';

class PlacementPage extends StatelessWidget {
  const PlacementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Para esta versión simplificada, usamos mocks
    return BlocProvider(
      create:
          (context) => PlacementBloc(
            searchProduct: SearchProduct(MockPlacementRepository()),
            updateLocation: UpdateLocation(MockPlacementRepository()),
            updateStock: UpdateStock(MockPlacementRepository()),
          ),
      child: _PlacementPageContent(),
    );
  }
}

class _PlacementPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Colocación'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<PlacementBloc, PlacementState>(
        listener: (context, state) {
          if (state is PlacementError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is LocationUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ubicación actualizada correctamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is StockUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stock actualizado correctamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is PlacementLoading,
            child: Column(
              children: [
                SelkSearchBar(
                  onSearch: (value) {
                    context.read<PlacementBloc>().add(
                      SearchProductEvent(barcode: value),
                    );
                  },
                  autofocus: true,
                  hintText: 'Escanear código de barras del producto',
                ),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.label), label: 'Etiquetas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Cerrar Sesión',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pop();
          } else if (index == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => LabelsPage()));
          } else if (index == 2) {
            // Cerrar sesión - implementar lógica
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlacementState state) {
    if (state is ProductFound ||
        state is LocationUpdateSuccess ||
        state is StockUpdateSuccess) {
      final product =
          state is ProductFound
              ? state.product
              : state is LocationUpdateSuccess
              ? state.updatedProduct
              : (state as StockUpdateSuccess).updatedProduct;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProductCard(
          product: product,
          showEditIcons: true,
          onFieldUpdate: (field, value) {
            if (field == 'location') {
              context.read<PlacementBloc>().add(
                UpdateLocationEvent(productId: product.id, newLocation: value),
              );
            } else if (field == 'stock') {
              final newStock = double.tryParse(value);
              if (newStock != null) {
                context.read<PlacementBloc>().add(
                  UpdateStockEvent(productId: product.id, newStock: newStock),
                );
              }
            }
          },
        ),
      );
    } else if (state is ProductNotFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Producto no encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<PlacementBloc>().add(ResetEvent());
              },
              child: Text('Nueva búsqueda'),
            ),
          ],
        ),
      );
    } else if (state is PlacementInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Escanee un código de barras',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Los datos del producto aparecerán aquí',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container();
  }
}

class MockPlacementRepository implements PlacementRepository {
  // Productos de ejemplo
  final _products = {
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

    final product = _products.values.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Producto no encontrado'),
    );

    final updatedProduct = product.copyWith(location: newLocation);

    // Actualizar el producto en el mapa
    _products[updatedProduct.barcode] = updatedProduct;

    return Right(updatedProduct);
  }

  @override
  Future<Either<Failure, Product>> updateProductStock(
    String productId,
    double newStock,
  ) async {
    await Future.delayed(Duration(seconds: 1)); // Simular latencia

    final product = _products.values.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Producto no encontrado'),
    );

    final updatedProduct = product.copyWith(stock: newStock);

    // Actualizar el producto en el mapa
    _products[updatedProduct.barcode] = updatedProduct;

    return Right(updatedProduct);
  }

  @override
  Future<Either<Failure, List<Label>>> getPendingLabels() async {
    // Implementar para la pantalla de etiquetas
    return Right([]);
  }

  @override
  Future<Either<Failure, List<Label>>> printLabels(
    List<String> labelIds,
  ) async {
    // Implementar para la pantalla de etiquetas
    return Right([]);
  }

  @override
  Future<Either<Failure, void>> deleteLabel(String labelId) async {
    // Implementar para la pantalla de etiquetas
    return Right(null);
  }
}

class NotFoundFailure extends Failure {
  NotFoundFailure(String message) : super(message);
}
