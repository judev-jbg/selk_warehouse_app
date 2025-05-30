import 'package:equatable/equatable.dart';

abstract class LoadOrderPickingEvent extends Equatable {
  const LoadOrderPickingEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentProductEvent extends LoadOrderPickingEvent {
  final String loadOrderId;

  const LoadCurrentProductEvent({required this.loadOrderId});

  @override
  List<Object?> get props => [loadOrderId];
}

class ScanProductEvent extends LoadOrderPickingEvent {
  final String barcode;
  final String loadOrderId;
  final String orderLineId;

  const ScanProductEvent({
    required this.barcode,
    required this.loadOrderId,
    required this.orderLineId,
  });

  @override
  List<Object?> get props => [barcode, loadOrderId, orderLineId];
}

class ConfirmPickingEvent extends LoadOrderPickingEvent {
  final String loadOrderId;
  final String orderLineId;
  final double quantity;
  final bool forceIncomplete;

  const ConfirmPickingEvent({
    required this.loadOrderId,
    required this.orderLineId,
    required this.quantity,
    this.forceIncomplete = false,
  });

  @override
  List<Object?> get props => [
    loadOrderId,
    orderLineId,
    quantity,
    forceIncomplete,
  ];
}

class MoveToNextProductEvent extends LoadOrderPickingEvent {
  final String loadOrderId;

  const MoveToNextProductEvent({required this.loadOrderId});

  @override
  List<Object?> get props => [loadOrderId];
}

class FinishPickingEvent extends LoadOrderPickingEvent {
  final String loadOrderId;

  const FinishPickingEvent({required this.loadOrderId});

  @override
  List<Object?> get props => [loadOrderId];
}
