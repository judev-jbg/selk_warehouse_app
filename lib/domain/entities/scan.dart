import 'package:equatable/equatable.dart';
import 'product.dart';

class Scan extends Equatable {
  final String id;
  final Product product;
  final double quantity;
  final String createdAt;
  final String? orderId;
  final String? supplierId;

  const Scan({
    required this.id,
    required this.product,
    required this.quantity,
    required this.createdAt,
    this.orderId,
    this.supplierId,
  });

  @override
  List<Object?> get props => [
    id,
    product,
    quantity,
    createdAt,
    orderId,
    supplierId,
  ];
}
