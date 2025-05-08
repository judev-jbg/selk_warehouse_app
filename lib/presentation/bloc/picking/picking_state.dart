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

  const LoadOrdersLoaded(this.loadOrders, {this.filter});

  @override
  List<Object?> get props => [loadOrders, filter];
}

class LoadOrdersEmpty extends PickingState {}

class PickingError extends PickingState {
  final String message;

  const PickingError(this.message);

  @override
  List<Object?> get props => [message];
}
