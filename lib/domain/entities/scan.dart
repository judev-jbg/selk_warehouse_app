import 'package:equatable/equatable.dart';
import 'product.dart';
import 'supplier.dart';

class Scan extends Equatable {
  final String id;
  final Product product;
  final double quantity;
  final String createdAt;
  final String? orderId;
  final Supplier? supplier;
  final String? userId;
  final bool synced;

  const Scan({
    required this.id,
    required this.product,
    required this.quantity,
    required this.createdAt,
    this.orderId,
    this.supplier,
    this.userId,
    this.synced = false,
  });

  Scan copyWith({
    String? id,
    Product? product,
    double? quantity,
    String? createdAt,
    String? orderId,
    Supplier? supplier,
    String? userId,
    bool? synced,
  }) {
    return Scan(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      supplier: supplier ?? this.supplier,
      userId: userId ?? this.userId,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
    id,
    product,
    quantity,
    createdAt,
    orderId,
    supplier,
    userId,
    synced,
  ];
}
