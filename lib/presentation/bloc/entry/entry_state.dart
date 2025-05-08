import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/scan.dart';

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
  final bool isNewScan;

  const ProductScanned({
    required this.product,
    required this.quantity,
    this.isNewScan = true,
  });

  @override
  List<Object?> get props => [product, quantity, isNewScan];
}

class ProductNotFound extends EntryState {
  final String message;

  const ProductNotFound(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductNotOrdered extends EntryState {
  final Product product;
  final String message;

  const ProductNotOrdered({required this.product, required this.message});

  @override
  List<Object?> get props => [product, message];
}

class ScansLoaded extends EntryState {
  final List<Scan> scans;

  const ScansLoaded(this.scans);

  @override
  List<Object?> get props => [scans];
}

class SpecialProductsFound extends EntryState {
  final List<Product> products;
  final String query;

  const SpecialProductsFound({required this.products, required this.query});

  @override
  List<Object?> get props => [products, query];
}

class SpecialProductsNotFound extends EntryState {
  final String query;
  final String message;

  const SpecialProductsNotFound({required this.query, required this.message});

  @override
  List<Object?> get props => [query, message];
}

class EntryError extends EntryState {
  final String message;

  const EntryError(this.message);

  @override
  List<Object?> get props => [message];
}
