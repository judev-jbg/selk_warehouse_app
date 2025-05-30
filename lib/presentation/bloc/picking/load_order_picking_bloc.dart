import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/picking/get_load_order_detail.dart';
import '../../../domain/usecases/picking/register_product_picking.dart';
import '../../../domain/entities/order_line.dart';
import '../../../domain/entities/load_order.dart';
import 'load_order_picking_event.dart';
import 'load_order_picking_state.dart';

class LoadOrderPickingBloc
    extends Bloc<LoadOrderPickingEvent, LoadOrderPickingState> {
  final GetLoadOrderDetail getLoadOrderDetail;
  final RegisterProductPicking registerProductPicking;

  // Índice del producto actual en la recogida
  int _currentProductIndex = 0;

  // Almacena la orden de carga actual
  LoadOrder? _loadOrder;

  LoadOrderPickingBloc({
    required this.getLoadOrderDetail,
    required this.registerProductPicking,
  }) : super(LoadOrderPickingInitial()) {
    on<LoadCurrentProductEvent>(_onLoadCurrentProduct);
    on<ScanProductEvent>(_onScanProduct);
    on<ConfirmPickingEvent>(_onConfirmPicking);
    on<MoveToNextProductEvent>(_onMoveToNextProduct);
    on<FinishPickingEvent>(_onFinishPicking);
  }

  Future<void> _onLoadCurrentProduct(
    LoadCurrentProductEvent event,
    Emitter<LoadOrderPickingState> emit,
  ) async {
    emit(LoadOrderPickingLoading());

    final result = await getLoadOrderDetail(
      GetLoadOrderDetailParams(loadOrderId: event.loadOrderId),
    );

    result.fold((failure) => emit(LoadOrderPickingError(failure.message)), (
      loadOrder,
    ) {
      _loadOrder = loadOrder;

      // Ordenar las líneas por ubicación
      final sortedLines = List<OrderLine>.from(loadOrder.lines)
        ..sort((a, b) => a.product.location.compareTo(b.product.location));

      // Encontrar el primer producto pendiente
      final pendingLines =
          sortedLines
              .where((line) => line.status == OrderLineStatus.pending)
              .toList();

      if (pendingLines.isEmpty) {
        emit(
          PickingCompleted(
            loadOrder: loadOrder,
            totalProductsPicked: loadOrder.completedProducts,
          ),
        );
      } else {
        _currentProductIndex = sortedLines.indexOf(pendingLines.first);

        emit(
          CurrentProductLoaded(
            orderLine: pendingLines.first,
            currentIndex: _currentProductIndex + 1,
            totalProducts: sortedLines.length,
            loadOrder: loadOrder,
          ),
        );
      }
    });
  }

  Future<void> _onScanProduct(
    ScanProductEvent event,
    Emitter<LoadOrderPickingState> emit,
  ) async {
    if (_loadOrder == null) {
      emit(LoadOrderPickingError('No se ha cargado ninguna orden de carga'));
      return;
    }

    final orderLine = _loadOrder!.lines.firstWhere(
      (line) => line.id == event.orderLineId,
      orElse: () => throw Exception('Línea de pedido no encontrada'),
    );

    final isCorrectProduct = orderLine.product.barcode == event.barcode;

    emit(
      ProductScanned(
        isCorrectProduct: isCorrectProduct,
        orderLine: orderLine,
        barcode: event.barcode,
      ),
    );
  }

  Future<void> _onConfirmPicking(
    ConfirmPickingEvent event,
    Emitter<LoadOrderPickingState> emit,
  ) async {
    emit(LoadOrderPickingLoading());

    final result = await registerProductPicking(
      RegisterProductPickingParams(
        loadOrderId: event.loadOrderId,
        orderLineId: event.orderLineId,
        quantity: event.quantity,
        forceIncomplete: event.forceIncomplete,
      ),
    );

    result.fold((failure) => emit(LoadOrderPickingError(failure.message)), (
      updatedOrderLine,
    ) {
      if (_loadOrder == null) {
        emit(LoadOrderPickingError('No se ha cargado ninguna orden de carga'));
        return;
      }

      // Actualizar la línea en la copia local
      final updatedLines =
          _loadOrder!.lines.map((line) {
            if (line.id == updatedOrderLine.id) {
              return updatedOrderLine;
            }
            return line;
          }).toList();

      _loadOrder = _loadOrder!.copyWith(
        lines: updatedLines,
        completedProducts: _loadOrder!.completedProducts + 1,
      );

      // Verificar si la recogida es completa o incompleta
      if (updatedOrderLine.status == OrderLineStatus.incomplete) {
        // Manejo de recogida incompleta
        emit(
          PickingIncomplete(
            orderLine: updatedOrderLine,
            remainingQuantity: updatedOrderLine.pendingQuantity,
            distributionInfo: updatedOrderLine.distributionInfo,
          ),
        );
      } else {
        // Contar cuántos productos quedan por recoger
        final remainingProducts =
            updatedLines
                .where((line) => line.status == OrderLineStatus.pending)
                .length;

        emit(
          ProductPicked(
            orderLine: updatedOrderLine,
            isComplete: true,
            remainingProducts: remainingProducts,
          ),
        );
      }
    });
  }

  Future<void> _onMoveToNextProduct(
    MoveToNextProductEvent event,
    Emitter<LoadOrderPickingState> emit,
  ) async {
    if (_loadOrder == null) {
      emit(LoadOrderPickingError('No se ha cargado ninguna orden de carga'));
      return;
    }

    // Ordenar las líneas por ubicación
    final sortedLines = List<OrderLine>.from(_loadOrder!.lines)
      ..sort((a, b) => a.product.location.compareTo(b.product.location));

    // Encontrar el siguiente producto pendiente
    final pendingLines =
        sortedLines
            .where((line) => line.status == OrderLineStatus.pending)
            .toList();

    if (pendingLines.isEmpty) {
      emit(
        PickingCompleted(
          loadOrder: _loadOrder!,
          totalProductsPicked: _loadOrder!.completedProducts,
        ),
      );
    } else {
      _currentProductIndex = sortedLines.indexOf(pendingLines.first);

      emit(
        CurrentProductLoaded(
          orderLine: pendingLines.first,
          currentIndex: _currentProductIndex + 1,
          totalProducts: sortedLines.length,
          loadOrder: _loadOrder!,
        ),
      );
    }
  }

  Future<void> _onFinishPicking(
    FinishPickingEvent event,
    Emitter<LoadOrderPickingState> emit,
  ) async {
    if (_loadOrder == null) {
      emit(LoadOrderPickingError('No se ha cargado ninguna orden de carga'));
      return;
    }

    // Contar productos recogidos
    final pickedProducts =
        _loadOrder!.lines
            .where(
              (line) =>
                  line.status == OrderLineStatus.completed ||
                  line.status == OrderLineStatus.incomplete,
            )
            .length;

    emit(
      PickingCompleted(
        loadOrder: _loadOrder!,
        totalProductsPicked: pickedProducts,
      ),
    );
  }
}
