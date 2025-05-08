import 'package:equatable/equatable.dart';
import 'supplier.dart';

enum OrderStatus { pending, partiallyReceived, completed, cancelled }

class Order extends Equatable {
  final String id;
  final String number;
  final String createdAt;
  final OrderStatus status;
  final Supplier? supplier;
  final List<OrderLine> lines;

  const Order({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.status,
    this.supplier,
    required this.lines,
  });

  @override
  List<Object?> get props => [id, number, createdAt, status, supplier, lines];
}

class OrderLine extends Equatable {
  final String id;
  final String productId;
  final String productReference;
  final String productDescription;
  final String? productBarcode;
  final double quantity;
  final double receivedQuantity;
  final double pendingQuantity;
  final String unit;
  final OrderLineStatus status;

  const OrderLine({
    required this.id,
    required this.productId,
    required this.productReference,
    required this.productDescription,
    this.productBarcode,
    required this.quantity,
    this.receivedQuantity = 0,
    required this.pendingQuantity,
    required this.unit,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    productReference,
    productDescription,
    productBarcode,
    quantity,
    receivedQuantity,
    pendingQuantity,
    unit,
    status,
  ];
}

enum OrderLineStatus { pending, partiallyReceived, completed, cancelled }
