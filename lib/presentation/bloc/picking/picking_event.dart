import 'package:equatable/equatable.dart';
import '../../../domain/entities/load_order.dart';

abstract class PickingEvent extends Equatable {
  const PickingEvent();

  @override
  List<Object?> get props => [];
}

class GetLoadOrdersEvent extends PickingEvent {
  final LoadOrderStatus? status;

  const GetLoadOrdersEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class FilterLoadOrdersEvent extends PickingEvent {
  final LoadOrderStatus? status;

  const FilterLoadOrdersEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class GetLoadOrderDetailEvent extends PickingEvent {
  final String loadOrderId;

  const GetLoadOrderDetailEvent({required this.loadOrderId});

  @override
  List<Object?> get props => [loadOrderId];
}

class StartPickingProcessEvent extends PickingEvent {
  final String loadOrderId;

  const StartPickingProcessEvent({required this.loadOrderId});

  @override
  List<Object?> get props => [loadOrderId];
}

class ResetPickingEvent extends PickingEvent {}
