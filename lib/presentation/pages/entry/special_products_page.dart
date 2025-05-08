import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/product.dart';
import '../../bloc/entry/entry_bloc.dart';
import '../../bloc/entry/entry_event.dart';
import '../../bloc/entry/entry_state.dart';
import '../../widgets/common/loading_overlay.dart';

class SpecialProductsPage extends StatelessWidget {
  const SpecialProductsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<EntryBloc>(context),
      child: _SpecialProductsPageContent(),
    );
  }
}

class _SpecialProductsPageContent extends StatefulWidget {
  @override
  _SpecialProductsPageContentState createState() =>
      _SpecialProductsPageContentState();
}

class _SpecialProductsPageContentState
    extends State<_SpecialProductsPageContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar productos 9999'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por referencia o descripción',
                hintText: 'Ejemplo: 9999 503',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<EntryBloc>().add(
                    SearchSpecialProductsEvent(query: value),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<EntryBloc, EntryState>(
              listener: (context, state) {
                if (state is EntryError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                return LoadingOverlay(
                  isLoading: state is EntryLoading,
                  child: _buildContent(context, state),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, EntryState state) {
    if (state is SpecialProductsFound) {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                product.description,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ref: ${product.reference}'),
                  if (product.location.isNotEmpty)
                    Text('Ubicación: ${product.location}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _showQuantityDialog(context, product);
                },
                child: Text('Seleccionar'),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      );
    } else if (state is SpecialProductsNotFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Busque productos especiales (9999)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ingrese una referencia o descripción',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                _searchController.text = '9999';
                context.read<EntryBloc>().add(
                  SearchSpecialProductsEvent(query: '9999'),
                );
              },
              child: Text('Buscar todos los 9999'),
            ),
          ],
        ),
      );
    }
  }

  void _showQuantityDialog(BuildContext context, Product product) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Registrar producto 9999'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.description,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Ref: ${product.reference}'),
                SizedBox(height: 16),
                TextField(
                  controller: quantityController,
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
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  final quantity =
                      double.tryParse(quantityController.text) ?? 1;

                  context.read<EntryBloc>().add(
                    RegisterSpecialProductEvent(
                      product: product,
                      quantity: quantity,
                    ),
                  );

                  Navigator.of(
                    context,
                  ).pop(); // Regresar a la pantalla de entrada
                },
                child: Text('Registrar'),
              ),
            ],
          ),
    );
  }
}
