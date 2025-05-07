import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String reference;
  final String description;
  final String barcode;
  final String location;
  final double stock;
  final String unit;
  final String status;

  const Product({
    required this.id,
    required this.reference,
    required this.description,
    required this.barcode,
    required this.location,
    required this.stock,
    required this.unit,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    reference,
    description,
    barcode,
    location,
    stock,
    unit,
    status,
  ];
}
