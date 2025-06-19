// lib/features/colocacion/domain/entities/label.dart
import 'package:equatable/equatable.dart';
import 'product.dart';

class Label extends Equatable {
  final String id;
  final Product product;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPrinted;
  final String status; // 'pending', 'printed', 'cancelled'

  const Label({
    required this.id,
    required this.product,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.isPrinted = false,
    this.status = 'pending',
  });

  @override
  List<Object?> get props => [
        id,
        product,
        location,
        createdAt,
        updatedAt,
        isPrinted,
        status,
      ];

  Label copyWith({
    String? id,
    Product? product,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPrinted,
    String? status,
  }) {
    return Label(
      id: id ?? this.id,
      product: product ?? this.product,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPrinted: isPrinted ?? this.isPrinted,
      status: status ?? this.status,
    );
  }

  // Getters de conveniencia
  bool get canBePrinted => status == 'pending' && !isPrinted;
  bool get canBeDeleted => status == 'pending';
  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'printed':
        return 'Impresa';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Desconocido';
    }
  }
}
