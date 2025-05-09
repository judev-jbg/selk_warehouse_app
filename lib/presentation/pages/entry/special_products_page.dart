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
  final _orderNumberController = TextEditingController();
  String? _selectedOrderNumber;

  @override
  void dispose() {
    _orderNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar articulos 9999'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingrese número de pedido',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _orderNumberController,
                  decoration: InputDecoration(
                    labelText: 'Número de pedido',
                    hintText: 'Ejemplo: PO-2025-0001',
                    prefixIcon: Icon(Icons.numbers),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        if (_orderNumberController.text.isNotEmpty) {
                          setState(() {
                            _selectedOrderNumber = _orderNumberController.text;
                          });
                          context.read<EntryBloc>().add(
                            SearchSpecialProductsEvent(
                              query: _orderNumberController.text,
                            ),
                          );
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _selectedOrderNumber = value;
                      });
                      context.read<EntryBloc>().add(
                        SearchSpecialProductsEvent(query: value),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          if (_selectedOrderNumber != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Pedido: $_selectedOrderNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedOrderNumber = null;
                        });
                        context.read<EntryBloc>().add(ResetScanEvent());
                      },
                      child: Icon(
                        Icons.clear,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: BlocConsumer<EntryBloc, EntryState>(
              listener: (context, state) {
                if (state is EntryError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                } else if (state is ProductScanned) {
                  // Ahora mostramos un mensaje al registrar un producto 9999
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Articulo agregado correctamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  // Navegamos de vuelta a la pantalla de entrada
                  Navigator.of(context).pop();
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

          // Datos del proveedor y cantidad pedida (mockup por ahora)
          final supplierName = "Proveedor Ejemplo S.L.";
          final orderedQuantity = 10.0;

          return Card(
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.numbers, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Ref: ${product.reference}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Proveedor: $supplierName',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Cantidad pedida: $orderedQuantity ${product.unit}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showQuantityDialog(
                            context,
                            product,
                            orderedQuantity,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text('Seleccionar'),
                      ),
                    ],
                  ),
                ],
              ),
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
              'No se encontraron articulos 9999',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
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
              'Busque articulos (9999)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ingrese un número de pedido para ver los productos 9999 asociados',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  void _showQuantityDialog(
    BuildContext context,
    Product product,
    double orderedQuantity,
  ) {
    final quantityController = TextEditingController(
      text: orderedQuantity.toString(),
    );
    bool isValidQuantity = true;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Agregar articulo 9999'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.description,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Ref: ${product.reference}'),
                    SizedBox(height: 8),
                    Text(
                      'Cantidad pedida: $orderedQuantity ${product.unit}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad a registrar',
                        border: OutlineInputBorder(),
                        errorText:
                            !isValidQuantity
                                ? 'La cantidad debe ser igual a la pedida'
                                : null,
                      ),
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      onChanged: (value) {
                        final enteredQuantity = double.tryParse(value) ?? 0;
                        setState(() {
                          isValidQuantity = enteredQuantity == orderedQuantity;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nota: La cantidad a registrar debe coincidir con la cantidad pedida.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed:
                        isValidQuantity
                            ? () {
                              Navigator.of(dialogContext).pop();

                              final quantity =
                                  double.tryParse(quantityController.text) ??
                                  orderedQuantity;

                              context.read<EntryBloc>().add(
                                RegisterSpecialProductEvent(
                                  product: product,
                                  quantity: quantity,
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text('Registrar'),
                  ),
                ],
              );
            },
          ),
    );
  }
}
