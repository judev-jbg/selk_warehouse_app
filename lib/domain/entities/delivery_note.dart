import 'package:equatable/equatable.dart';
import 'supplier.dart';
import 'scan.dart';

enum DeliveryNoteStatus { draft, confirmed, cancelled }

class DeliveryNote extends Equatable {
  final String id;
  final String number;
  final String createdAt;
  final DeliveryNoteStatus status;
  final Supplier supplier;
  final String? supplierReference;
  final List<Scan> scans;
  final String? userId;

  const DeliveryNote({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.status,
    required this.supplier,
    this.supplierReference,
    required this.scans,
    this.userId,
  });

  @override
  List<Object?> get props => [
    id,
    number,
    createdAt,
    status,
    supplier,
    supplierReference,
    scans,
    userId,
  ];
}
