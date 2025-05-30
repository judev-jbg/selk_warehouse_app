import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_line.dart';
import '../../../domain/entities/load_order.dart';

abstract class LoadOrderPickingState extends Equatable {
  const LoadOrderPickingState();

  @override
  List<Object?> get props => [];
}

class LoadOrderPickingInitial extends LoadOrderPickingState {}

class LoadOrderPickingLoading extends LoadOrderPickingState {}

class CurrentProductLoaded extends LoadOrderPickingState {
  final OrderLine orderLine;
  final int currentIndex;
  final int totalProducts;
  final LoadOrder loadOrder;

  const CurrentProductLoaded({
    required this.orderLine,
    required this.currentIndex,
    required this.totalProducts,
    required this.loadOrder,
  });

  @override
  List<Object?> get props => [
    orderLine,
    currentIndex,
    totalProducts,
    loadOrder,
  ];
}

class ProductScanned extends LoadOrderPickingState {
  final bool isCorrectProduct;
  final OrderLine orderLine;
  final String barcode;

  const ProductScanned({
    required this.isCorrectProduct,
    required this.orderLine,
    required this.barcode,
  });

  @override
  List<Object?> get props => [isCorrectProduct, orderLine, barcode];
}

class ProductPicked extends LoadOrderPickingState {
  final OrderLine orderLine;
  final bool isComplete;
  final int remainingProducts;

  const ProductPicked({
    required this.orderLine,
    required this.isComplete,
    required this.remainingProducts,
  });

  @override
  List<Object?> get props => [orderLine, isComplete, remainingProducts];
}

class PickingIncomplete extends LoadOrderPickingState {
  final OrderLine orderLine;
  final double remainingQuantity;
  final String distributionInfo;

  const PickingIncomplete({
    required this.orderLine,
    required this.remainingQuantity,
    required this.distributionInfo,
  });

  @override
  List<Object?> get props => [orderLine, remainingQuantity, distributionInfo];
}

class PickingCompleted extends LoadOrderPickingState {
  final LoadOrder loadOrder;
  final int totalProductsPicked;

  const PickingCompleted({
    required this.loadOrder,
    required this.totalProductsPicked,
  });

  @override
  List<Object?> get props => [loadOrder, totalProductsPicked];
}

class LoadOrderPickingError extends LoadOrderPickingState {
  final String message;

  const LoadOrderPickingError(this.message);

  @override
  List<Object?> get props => [message];
}
