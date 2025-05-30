import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/load_order.dart';
import '../../../domain/entities/order_line.dart';
import '../../bloc/picking/picking_bloc.dart';
import '../../bloc/picking/picking_event.dart';
import '../../bloc/picking/picking_state.dart';
import '../../widgets/common/loading_overlay.dart';
import 'picking_process_page.dart';
import 'load_order_summary_page.dart';

class LoadOrderDetailPage extends StatelessWidget {
  final String loadOrderId;

  const LoadOrderDetailPage({Key? key, required this.loadOrderId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<PickingBloc>(context)
        ..add(GetLoadOrderDetailEvent(loadOrderId: loadOrderId)),
      child: _LoadOrderDetailPageContent(loadOrderId: loadOrderId),
    );
  }
}

class _LoadOrderDetailPageContent extends StatelessWidget {
  final String loadOrderId;

  const _LoadOrderDetailPageContent({required this.loadOrderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Orden de Carga'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<PickingBloc, PickingState>(
        listener: (context, state) {
          if (state is PickingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is PickingStarted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PickingProcessPage(loadOrderId: loadOrderId),
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is PickingLoading,
            child:
                state is LoadOrderDetailLoaded
                    ? _buildContent(context, state.loadOrder)
                    : SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, LoadOrder loadOrder) {
    return Column(
      children: [
        _buildHeader(context, loadOrder),
        Expanded(child: _buildProductsList(context, loadOrder)),
        _buildActionButtons(context, loadOrder),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, LoadOrder loadOrder) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Orden #${loadOrder.number}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(loadOrder.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(loadOrder.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Fecha: ${loadOrder.createdAt}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Productos: ${loadOrder.totalProducts}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                'Recogidos: ${loadOrder.completedProducts}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value:
                loadOrder.totalProducts > 0
                    ? loadOrder.completedProducts / loadOrder.totalProducts
                    : 0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(loadOrder.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, LoadOrder loadOrder) {
    // Ordenar las líneas por ubicación
    final sortedLines = List<OrderLine>.from(loadOrder.lines)
      ..sort((a, b) => a.product.location.compareTo(b.product.location));

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sortedLines.length,
      itemBuilder: (context, index) {
        final orderLine = sortedLines[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductStatusIcon(orderLine.status),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderLine.product.description,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.storage,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Ubicación: ${orderLine.product.location}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.view_module,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Ref: ${orderLine.product.reference}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Cantidad: ${orderLine.quantity} ${orderLine.product.unit}',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (orderLine.status == OrderLineStatus.completed ||
                              orderLine.status == OrderLineStatus.incomplete)
                            Text(
                              'Recogido: ${orderLine.collectedQuantity} ${orderLine.product.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    orderLine.status ==
                                            OrderLineStatus.incomplete
                                        ? AppColors.warning
                                        : AppColors.success,
                              ),
                            ),
                        ],
                      ),
                      if (orderLine.distributionInfo.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          'Distribución: ${orderLine.distributionInfo}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, LoadOrder loadOrder) {
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
          if (loadOrder.status == LoadOrderStatus.completed ||
              loadOrder.status == LoadOrderStatus.incomplete)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => LoadOrderSummaryPage(loadOrderId: loadOrderId),
                    ),
                  );
                },
                child: Text('Ver Resumen'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          if (loadOrder.status == LoadOrderStatus.pending ||
              loadOrder.status == LoadOrderStatus.inProgress ||
              loadOrder.status == LoadOrderStatus.incomplete) ...[
            if (loadOrder.status != LoadOrderStatus.pending)
              SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<PickingBloc>().add(
                    StartPickingProcessEvent(loadOrderId: loadOrderId),
                  );
                },
                child: Text(
                  loadOrder.status == LoadOrderStatus.pending
                      ? 'Iniciar Recogida'
                      : 'Continuar Recogida',
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductStatusIcon(OrderLineStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case OrderLineStatus.pending:
        icon = Icons.schedule;
        color = Colors.grey;
        break;
      case OrderLineStatus.completed:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case OrderLineStatus.incomplete:
        icon = Icons.warning;
        color = AppColors.warning;
        break;
      case OrderLineStatus.cancelled:
        icon = Icons.cancel;
        color = AppColors.error;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Color _getStatusColor(LoadOrderStatus status) {
    switch (status) {
      case LoadOrderStatus.pending:
        return Colors.grey;
      case LoadOrderStatus.inProgress:
        return AppColors.info;
      case LoadOrderStatus.incomplete:
        return AppColors.warning;
      case LoadOrderStatus.completed:
        return AppColors.success;
    }
  }

  String _getStatusText(LoadOrderStatus status) {
    switch (status) {
      case LoadOrderStatus.pending:
        return 'PENDIENTE';
      case LoadOrderStatus.inProgress:
        return 'EN PROCESO';
      case LoadOrderStatus.incomplete:
        return 'INCOMPLETO';
      case LoadOrderStatus.completed:
        return 'COMPLETADO';
    }
  }
}
