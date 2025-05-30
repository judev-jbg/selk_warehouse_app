import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/order_line.dart';
import '../../bloc/picking/load_order_picking_bloc.dart';
import '../../bloc/picking/load_order_picking_event.dart';
import '../../bloc/picking/load_order_picking_state.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/search_bar.dart';
import 'load_order_summary_page.dart';

class PickingProcessPage extends StatelessWidget {
  final String loadOrderId;

  const PickingProcessPage({Key? key, required this.loadOrderId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => LoadOrderPickingBloc(
            getLoadOrderDetail: context.read(),
            registerProductPicking: context.read(),
          )..add(LoadCurrentProductEvent(loadOrderId: loadOrderId)),
      child: _PickingProcessPageContent(loadOrderId: loadOrderId),
    );
  }
}

class _PickingProcessPageContent extends StatelessWidget {
  final String loadOrderId;
  final TextEditingController _quantityController = TextEditingController();

  _PickingProcessPageContent({required this.loadOrderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proceso de Recogida'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<LoadOrderPickingBloc, LoadOrderPickingState>(
        listener: (context, state) {
          if (state is LoadOrderPickingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ProductScanned && !state.isCorrectProduct) {
            // Notificar cuando se escanea un producto incorrecto
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '¡Producto incorrecto! Verifique el código escaneado.',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is ProductPicked) {
            // Notificar cuando se recoge un producto correctamente
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Producto recogido correctamente'),
                backgroundColor: AppColors.success,
              ),
            );

            // Avanzar al siguiente producto tras un breve retraso
            Future.delayed(Duration(seconds: 1), () {
              if (context.mounted) {
                context.read<LoadOrderPickingBloc>().add(
                  MoveToNextProductEvent(loadOrderId: loadOrderId),
                );
              }
            });
          } else if (state is PickingIncomplete) {
            _showIncompleteDialog(context, state);
          } else if (state is PickingCompleted) {
            // Navegar a la página de resumen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoadOrderSummaryPage(loadOrderId: loadOrderId),
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is LoadOrderPickingLoading,
            child: _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, LoadOrderPickingState state) {
    if (state is CurrentProductLoaded) {
      return Column(
        children: [
          _buildProgressIndicator(state.currentIndex, state.totalProducts),
          _buildProductCard(context, state.orderLine),
          SelkSearchBar(
            onSearch: (barcode) {
              context.read<LoadOrderPickingBloc>().add(
                ScanProductEvent(
                  barcode: barcode,
                  loadOrderId: loadOrderId,
                  orderLineId: state.orderLine.id,
                ),
              );
            },
            autofocus: true,
            hintText: 'Escanear código de barras del producto',
          ),
          Spacer(),
          _buildBottomButtons(context, state.orderLine),
        ],
      );
    } else if (state is ProductScanned && state.isCorrectProduct) {
      _quantityController.text = state.orderLine.quantity.toString();

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Producto correcto!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildProductCard(context, state.orderLine),
                  SizedBox(height: 24),
                  Text(
                    'Cantidad a recoger:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      hintText: 'Ingrese la cantidad recogida',
                      border: OutlineInputBorder(),
                      suffixText: state.orderLine.product.unit,
                    ),
                    keyboardType: TextInputType.number,
                    autofocus: true,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nota: La cantidad a recoger debe ser ${state.orderLine.quantity} ${state.orderLine.product.unit}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (state.orderLine.distributionInfo.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Distribución: ${state.orderLine.distributionInfo}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Debe separar las unidades según esta distribución',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildConfirmButtons(context, state.orderLine),
        ],
      );
    } else if (state is PickingCompleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: AppColors.success),
            SizedBox(height: 16),
            Text(
              '¡Proceso de recogida completado!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Se han recogido ${state.totalProductsPicked} productos',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => LoadOrderSummaryPage(loadOrderId: loadOrderId),
                  ),
                );
              },
              child: Text('Ver Resumen'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildProgressIndicator(int current, int total) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recogiendo productos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '$current de $total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: total > 0 ? current / total : 0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, OrderLine orderLine) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              orderLine.product.description,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.storage,
                        'Ubicación:',
                        orderLine.product.location,
                      ),
                      SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.view_module,
                        'Referencia:',
                        orderLine.product.reference,
                      ),
                      SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.qr_code,
                        'Código de barras:',
                        orderLine.product.barcode,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Cantidad',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      Text(
                        '${orderLine.quantity}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        orderLine.product.unit,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (orderLine.distributionInfo.isNotEmpty) ...[
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              Text(
                'Distribución: ${orderLine.distributionInfo}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Pedidos a servir',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.black),
              children: [
                TextSpan(
                  text: '$label ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, OrderLine orderLine) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Confirmar manualmente sin escanear cuando hay un motivo válido
                _showConfirmWithoutScanDialog(context, orderLine);
              },
              icon: Icon(Icons.warning),
              label: Text('No puedo escanear este producto'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.amber[700],
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showSkipDialog(context, orderLine);
              },
              icon: Icon(Icons.skip_next),
              label: Text('Saltar este producto'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButtons(BuildContext context, OrderLine orderLine) {
    final enteredQuantity = double.tryParse(_quantityController.text) ?? 0;
    final isComplete = enteredQuantity >= orderLine.quantity;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Volver a escanear
                context.read<LoadOrderPickingBloc>().add(
                  LoadCurrentProductEvent(loadOrderId: loadOrderId),
                );
              },
              child: Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  enteredQuantity > 0
                      ? () {
                        final quantity =
                            double.tryParse(_quantityController.text) ?? 0;

                        if (quantity > 0) {
                          context.read<LoadOrderPickingBloc>().add(
                            ConfirmPickingEvent(
                              loadOrderId: loadOrderId,
                              orderLineId: orderLine.id,
                              quantity: quantity,
                              forceIncomplete: quantity < orderLine.quantity,
                            ),
                          );
                        }
                      }
                      : null,
              child: Text(isComplete ? 'Confirmar' : 'Confirmar Parcial'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    isComplete ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmWithoutScanDialog(
    BuildContext context,
    OrderLine orderLine,
  ) {
    _quantityController.text = orderLine.quantity.toString();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Confirmar sin escanear'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Si no puede escanear el producto, indique el motivo y la cantidad recogida:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Motivo',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'no_code',
                      child: Text('Producto sin código'),
                    ),
                    DropdownMenuItem(
                      value: 'damaged_code',
                      child: Text('Código dañado/ilegible'),
                    ),
                    DropdownMenuItem(
                      value: 'scanner_error',
                      child: Text('Error del escáner'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad',
                    hintText: 'Ingrese la cantidad recogida',
                    border: OutlineInputBorder(),
                    suffixText: orderLine.product.unit,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  final quantity =
                      double.tryParse(_quantityController.text) ?? 0;

                  if (quantity > 0) {
                    context.read<LoadOrderPickingBloc>().add(
                      ConfirmPickingEvent(
                        loadOrderId: loadOrderId,
                        orderLineId: orderLine.id,
                        quantity: quantity,
                        forceIncomplete: quantity < orderLine.quantity,
                      ),
                    );
                  }
                },
                child: Text('Confirmar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
              ),
            ],
          ),
    );
  }

  void _showSkipDialog(BuildContext context, OrderLine orderLine) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Saltar producto'),
            content: Text(
              '¿Está seguro que desea saltar este producto? Podrá volver a él más tarde.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  // Avanzar al siguiente producto
                  context.read<LoadOrderPickingBloc>().add(
                    MoveToNextProductEvent(loadOrderId: loadOrderId),
                  );
                },
                child: Text('Saltar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                ),
              ),
            ],
          ),
    );
  }

  void _showIncompleteDialog(BuildContext context, PickingIncomplete state) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Recogida incompleta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La cantidad recogida es menor a la solicitada:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12),
                _buildInfoRow(
                  Icons.check_circle,
                  'Recogido:',
                  '${state.orderLine.collectedQuantity} ${state.orderLine.product.unit}',
                ),
                SizedBox(height: 4),
                _buildInfoRow(
                  Icons.warning,
                  'Pendiente:',
                  '${state.remainingQuantity} ${state.orderLine.product.unit}',
                ),
                SizedBox(height: 16),
                Text(
                  'Instrucciones de distribución:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(state.distributionInfo),
                SizedBox(height: 8),
                Text(
                  'Distribuya las unidades recogidas según estas instrucciones.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  // Avanzar al siguiente producto
                  context.read<LoadOrderPickingBloc>().add(
                    MoveToNextProductEvent(loadOrderId: loadOrderId),
                  );
                },
                child: Text('Continuar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
              ),
            ],
          ),
    );
  }
}
