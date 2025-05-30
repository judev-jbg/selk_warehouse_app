import 'package:equatable/equatable.dart';
import '../../../domain/entities/load_order.dart';

abstract class PickingState extends Equatable {
  const PickingState();

  @override
  List<Object?> get props => [];
}

class PickingInitial extends PickingState {}

class PickingLoading extends PickingState {}

class LoadOrdersLoaded extends PickingState {
  final List<LoadOrder> loadOrders;
  final LoadOrderStatus? filter;

  const LoadOrdersLoaded({required this.loadOrders, this.filter});

  @override
  List<Object?> get props => [loadOrders, filter];
}

class LoadOrdersEmpty extends PickingState {
  final LoadOrderStatus? filter;

  const LoadOrdersEmpty({this.filter});

  @override
  List<Object?> get props => [filter];
}

class LoadOrderDetailLoaded extends PickingState {
  final LoadOrder loadOrder;

  const LoadOrderDetailLoaded(this.loadOrder);

  @override
  List<Object?> get props => [loadOrder];
}

class PickingStarted extends PickingState {
  final LoadOrder loadOrder;

  const PickingStarted(this.loadOrder);

  @override
  List<Object?> get props => [loadOrder];
}

class PickingError extends PickingState {
  final String message;

  const PickingError(this.message);

  @override
  List<Object?> get props => [message];
}
