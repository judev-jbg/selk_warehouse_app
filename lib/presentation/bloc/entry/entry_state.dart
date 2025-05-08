import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class EntryState extends Equatable {
  const EntryState();

  @override
  List<Object?> get props => [];
}

class EntryInitial extends EntryState {}

class EntryLoading extends EntryState {}

class ProductScanned extends EntryState {
  final Product product;
  final double quantity;

  const ProductScanned({required this.product, required this.quantity});

  @override
  List<Object?> get props => [product, quantity];
}

class ProductNotFound extends EntryState {
  final String message;

  const ProductNotFound(this.message);

  @override
  List<Object?> get props => [message];
}

class EntryError extends EntryState {
  final String message;

  const EntryError(this.message);

  @override
  List<Object?> get props => [message];
}
