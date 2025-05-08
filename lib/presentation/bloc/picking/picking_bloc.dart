import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/order.dart';
import 'picking_event.dart';
import 'picking_state.dart';

class PickingBloc extends Bloc<PickingEvent, PickingState> {
  // Temporalmente utiliza funciones vacías hasta que implementemos los casos de uso reales
  final dynamic getLoadOrders;

  PickingBloc({required this.getLoadOrders}) : super(PickingInitial()) {
    on<GetLoadOrdersEvent>(_onGetLoadOrders);
    on<FilterLoadOrdersEvent>(_onFilterLoadOrders);
  }

  Future<void> _onGetLoadOrders(
    GetLoadOrdersEvent event,
    Emitter<PickingState> emit,
  ) async {
    emit(PickingLoading());

    // Implementación temporal hasta que tengamos el repositorio real
    await Future.delayed(Duration(seconds: 1));

    // Para pruebas, creamos órdenes ficticias
    final mockLoadOrders = [
      LoadOrder(
        id: '1',
        number: '001',
        createdAt: '2023-08-01',
        status: LoadOrderStatus.pending,
        totalProducts: 10,
        completedProducts: 0,
      ),
      LoadOrder(
        id: '2',
        number: '002',
        createdAt: '2023-08-02',
        status: LoadOrderStatus.inProgress,
        totalProducts: 15,
        completedProducts: 5,
      ),
      LoadOrder(
        id: '3',
        number: '003',
        createdAt: '2023-08-03',
        status: LoadOrderStatus.incomplete,
        totalProducts: 8,
        completedProducts: 6,
      ),
      LoadOrder(
        id: '4',
        number: '004',
        createdAt: '2023-08-04',
        status: LoadOrderStatus.completed,
        totalProducts: 12,
        completedProducts: 12,
      ),
    ];

    if (mockLoadOrders.isEmpty) {
      emit(LoadOrdersEmpty());
    } else {
      emit(LoadOrdersLoaded(mockLoadOrders));
    }
  }

  void _onFilterLoadOrders(
    FilterLoadOrdersEvent event,
    Emitter<PickingState> emit,
  ) async {
    emit(PickingLoading());

    // Implementación temporal
    await Future.delayed(Duration(seconds: 1));

    // Simulamos un filtrado
    final mockLoadOrders = [
      LoadOrder(
        id: '1',
        number: '001',
        createdAt: '2023-08-01',
        status: LoadOrderStatus.pending,
        totalProducts: 10,
        completedProducts: 0,
      ),
      LoadOrder(
        id: '2',
        number: '002',
        createdAt: '2023-08-02',
        status: LoadOrderStatus.inProgress,
        totalProducts: 15,
        completedProducts: 5,
      ),
      LoadOrder(
        id: '3',
        number: '003',
        createdAt: '2023-08-03',
        status: LoadOrderStatus.incomplete,
        totalProducts: 8,
        completedProducts: 6,
      ),
      LoadOrder(
        id: '4',
        number: '004',
        createdAt: '2023-08-04',
        status: LoadOrderStatus.completed,
        totalProducts: 12,
        completedProducts: 12,
      ),
    ];

    // Filtramos las órdenes si se proporciona un filtro
    final filteredOrders =
        event.status == null
            ? mockLoadOrders
            : mockLoadOrders
                .where((order) => order.status == event.status)
                .toList();

    if (filteredOrders.isEmpty) {
      emit(LoadOrdersEmpty());
    } else {
      emit(LoadOrdersLoaded(filteredOrders, filter: event.status));
    }
  }
}
