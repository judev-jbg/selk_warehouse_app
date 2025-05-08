import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

abstract class EntryEvent extends Equatable {
  const EntryEvent();

  @override
  List<Object?> get props => [];
}

class ScanProductEvent extends EntryEvent {
  final String barcode;
  final String? orderId;
  final String? supplierId;

  const ScanProductEvent({
    required this.barcode,
    this.orderId,
    this.supplierId,
  });

  @override
  List<Object?> get props => [barcode, orderId, supplierId];
}

class RegisterSpecialProductEvent extends EntryEvent {
  final Product product;
  final double quantity;

  const RegisterSpecialProductEvent({
    required this.product,
    required this.quantity,
  });

  @override
  List<Object?> get props => [product, quantity];
}

class ResetScanEvent extends EntryEvent {}

class GetAllScansEvent extends EntryEvent {}

class ReceivedRealTimeScanEvent extends EntryEvent {
  final String barcode;
  final double quantity;
  final String userId;

  const ReceivedRealTimeScanEvent({
    required this.barcode,
    required this.quantity,
    required this.userId,
  });

  @override
  List<Object?> get props => [barcode, quantity, userId];
}

class SearchSpecialProductsEvent extends EntryEvent {
  final String query;

  const SearchSpecialProductsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}
