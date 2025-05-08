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

  Product copyWith({
    String? id,
    String? reference,
    String? description,
    String? barcode,
    String? location,
    double? stock,
    String? unit,
    String? status,
  }) {
    return Product(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      location: location ?? this.location,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      status: status ?? this.status,
    );
  }

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
