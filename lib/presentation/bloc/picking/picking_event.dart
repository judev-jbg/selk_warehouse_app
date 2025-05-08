import 'package:equatable/equatable.dart';
import '../../../domain/entities/order.dart';

abstract class PickingEvent extends Equatable {
  const PickingEvent();

  @override
  List<Object?> get props => [];
}

class GetLoadOrdersEvent extends PickingEvent {}

class FilterLoadOrdersEvent extends PickingEvent {
  final LoadOrderStatus? status;

  const FilterLoadOrdersEvent({this.status});

  @override
  List<Object?> get props => [status];
}
