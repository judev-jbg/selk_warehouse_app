import 'package:equatable/equatable.dart';
import 'order_line.dart';

enum CustomerDeliveryNoteStatus { draft, confirmed, cancelled }

class CustomerDeliveryNote extends Equatable {
  final String id;
  final String number;
  final String createdAt;
  final CustomerDeliveryNoteStatus status;
  final String customerId;
  final String customerName;
  final String deliveryAddress;
  final List<OrderLine> lines;
  final double volume;
  final double weight;
  final String? notes;

  const CustomerDeliveryNote({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.status,
    required this.customerId,
    required this.customerName,
    required this.deliveryAddress,
    required this.lines,
    required this.volume,
    required this.weight,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    number,
    createdAt,
    status,
    customerId,
    customerName,
    deliveryAddress,
    lines,
    volume,
    weight,
    notes,
  ];
}
