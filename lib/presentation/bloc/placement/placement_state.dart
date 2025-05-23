import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class PlacementState extends Equatable {
  const PlacementState();

  @override
  List<Object?> get props => [];
}

class PlacementInitial extends PlacementState {}

class PlacementLoading extends PlacementState {}

class ProductFound extends PlacementState {
  final Product product;

  const ProductFound(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductNotFound extends PlacementState {
  final String message;

  const ProductNotFound(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationUpdateSuccess extends PlacementState {
  final Product updatedProduct;

  const LocationUpdateSuccess(this.updatedProduct);

  @override
  List<Object?> get props => [updatedProduct];
}

class StockUpdateSuccess extends PlacementState {
  final Product updatedProduct;

  const StockUpdateSuccess(this.updatedProduct);

  @override
  List<Object?> get props => [updatedProduct];
}

class PlacementError extends PlacementState {
  final String message;

  const PlacementError(this.message);

  @override
  List<Object?> get props => [message];
}
