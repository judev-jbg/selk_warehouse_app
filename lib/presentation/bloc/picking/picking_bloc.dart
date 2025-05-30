import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/picking/get_load_orders.dart';
import '../../../domain/usecases/picking/get_load_order_detail.dart';
import '../../../domain/usecases/picking/start_picking_process.dart';
import '../../../domain/entities/load_order.dart';
import 'picking_event.dart';
import 'picking_state.dart';

class PickingBloc extends Bloc<PickingEvent, PickingState> {
  final GetLoadOrders getLoadOrders;
  final GetLoadOrderDetail getLoadOrderDetail;
  final StartPickingProcess startPickingProcess;

  PickingBloc({
    required this.getLoadOrders,
    required this.getLoadOrderDetail,
    required this.startPickingProcess,
  }) : super(PickingInitial()) {
    on<GetLoadOrdersEvent>(_onGetLoadOrders);
    on<FilterLoadOrdersEvent>(_onFilterLoadOrders);
    on<GetLoadOrderDetailEvent>(_onGetLoadOrderDetail);
    on<StartPickingProcessEvent>(_onStartPickingProcess);
    on<ResetPickingEvent>(_onResetPicking);
  }

  Future<void> _onGetLoadOrders(
    GetLoadOrdersEvent event,
    Emitter<PickingState> emit,
  ) async {
    emit(PickingLoading());

    final result = await getLoadOrders(
      GetLoadOrdersParams(status: event.status),
    );

    result.fold((failure) => emit(PickingError(failure.message)), (loadOrders) {
      if (loadOrders.isEmpty) {
        emit(LoadOrdersEmpty(filter: event.status));
      } else {
        emit(LoadOrdersLoaded(loadOrders: loadOrders, filter: event.status));
      }
    });
  }

  Future<void> _onFilterLoadOrders(
    FilterLoadOrdersEvent event,
    Emitter<PickingState> emit,
  ) async {
    emit(PickingLoading());

    final result = await getLoadOrders(
      GetLoadOrdersParams(status: event.status),
    );

    result.fold((failure) => emit(PickingError(failure.message)), (loadOrders) {
      if (loadOrders.isEmpty) {
        emit(LoadOrdersEmpty(filter: event.status));
      } else {
        emit(LoadOrdersLoaded(loadOrders: loadOrders, filter: event.status));
      }
    });
  }

  Future<void> _onGetLoadOrderDetail(
    GetLoadOrderDetailEvent event,
    Emitter<PickingState> emit,
  ) async {
    emit(PickingLoading());

    final result = await getLoadOrderDetail(
      GetLoadOrderDetailParams(loadOrderId: event.loadOrderId),
    );

    result.fold(
      (failure) => emit(PickingError(failure.message)),
      (loadOrder) => emit(LoadOrderDetailLoaded(loadOrder)),
    );
  }

  Future<void> _onStartPickingProcess(
    StartPickingProcessEvent event,
    Emitter<PickingState> emit,
  ) async {
    emit(PickingLoading());

    final result = await startPickingProcess(
      StartPickingProcessParams(loadOrderId: event.loadOrderId),
    );

    result.fold(
      (failure) => emit(PickingError(failure.message)),
      (loadOrder) => emit(PickingStarted(loadOrder)),
    );
  }

  void _onResetPicking(ResetPickingEvent event, Emitter<PickingState> emit) {
    emit(PickingInitial());
  }
}
