import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_color.dart';
import '../../bloc/placement/placement_bloc.dart';
import '../../bloc/placement/placement_event.dart';
import '../../bloc/placement/placement_state.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/loading_overlay.dart';
import 'labels_page.dart';

class PlacementPage extends StatelessWidget {
  const PlacementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => PlacementBloc(
            searchProduct: context.read(),
            updateLocation: context.read(),
            updateStock: context.read(),
          ),
      child: Scaffold(
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
            } else if (state is LocationUpdateSuccess ||
                state is StockUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state is LocationUpdateSuccess
                        ? 'Ubicación actualizada correctamente'
                        : 'Stock actualizado correctamente',
                  ),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.label),
              label: 'Etiquetas',
            ),
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
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlacementState state) {
    if (state is ProductFound) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProductCard(
          product: state.product,
          showEditIcons: true,
          onFieldUpdate: (field, value) {
            if (field == 'location') {
              context.read<PlacementBloc>().add(
                UpdateLocationEvent(
                  productId: state.product.id,
                  newLocation: value,
                ),
              );
            } else if (field == 'stock') {
              context.read<PlacementBloc>().add(
                UpdateStockEvent(
                  productId: state.product.id,
                  newStock: double.tryParse(value) ?? 0,
                ),
              );
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
              'Escanee otro código de barras para buscar',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
