import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/app_color.dart';
import '../../../domain/entities/load_order.dart';
import '../../bloc/picking/picking_bloc.dart';
import '../../bloc/picking/picking_event.dart';
import '../../bloc/picking/picking_state.dart';
import '../../bloc/picking/load_order_detail_page.dart';

class PickingPage extends StatelessWidget {
  const PickingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              PickingBloc(getLoadOrders: context.read())
                ..add(GetLoadOrdersEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recogida (Picking)'),
          backgroundColor: AppColors.primary,
        ),
        body: BlocConsumer<PickingBloc, PickingState>(
          listener: (context, state) {
            if (state is PickingError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is PickingLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is LoadOrdersLoaded) {
              return _buildLoadOrdersList(context, state.loadOrders);
            } else if (state is LoadOrdersEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay órdenes de carga pendientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Las órdenes de carga se mostrarán aquí cuando estén disponibles',
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
      ),
    );
  }

  Widget _buildLoadOrdersList(
    BuildContext context,
    List<LoadOrder> loadOrders,
  ) {
    return Column(
      children: [
        _buildStatusFilter(context),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: loadOrders.length,
            itemBuilder: (context, index) {
              final loadOrder = loadOrders[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                LoadOrderDetailPage(loadOrderId: loadOrder.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildStatusIcon(loadOrder.status),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orden #${loadOrder.number}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Fecha: ${loadOrder.createdAt}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value:
                                    loadOrder.totalProducts > 0
                                        ? loadOrder.completedProducts /
                                            loadOrder.totalProducts
                                        : 0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getStatusColor(loadOrder.status),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${loadOrder.completedProducts}/${loadOrder.totalProducts} productos',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(loadOrder.status),
                            borderRadius: BorderRadius.circular(8),
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip(context, 'Todos', null),
            SizedBox(width: 8),
            _buildFilterChip(context, 'Pendientes', LoadOrderStatus.pending),
            SizedBox(width: 8),
            _buildFilterChip(context, 'En Proceso', LoadOrderStatus.inProgress),
            SizedBox(width: 8),
            _buildFilterChip(
              context,
              'Incompletos',
              LoadOrderStatus.incomplete,
            ),
            SizedBox(width: 8),
            _buildFilterChip(context, 'Completados', LoadOrderStatus.completed),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    LoadOrderStatus? status,
  ) {
    return BlocBuilder<PickingBloc, PickingState>(
      builder: (context, state) {
        final isSelected = state is LoadOrdersLoaded && state.filter == status;

        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            context.read<PickingBloc>().add(
              FilterLoadOrdersEvent(status: status),
            );
          },
          backgroundColor: Colors.grey[200],
          selectedColor: AppColors.primaryLight,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(LoadOrderStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case LoadOrderStatus.pending:
        icon = Icons.schedule;
        color = Colors.grey;
        break;
      case LoadOrderStatus.inProgress:
        icon = Icons.sync;
        color = AppColors.info;
        break;
      case LoadOrderStatus.incomplete:
        icon = Icons.warning;
        color = AppColors.warning;
        break;
      case LoadOrderStatus.completed:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
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
