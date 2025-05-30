import 'package:equatable/equatable.dart';
import 'order_line.dart';

enum LoadOrderStatus {
  pending, // Pendiente (no se ha iniciado la recogida)
  inProgress, // En Proceso (se ha iniciado pero no completado)
  incomplete, // Incompleto (se han generado albaranes pero faltan productos)
  completed, // Completado (todos los productos han sido recogidos y albaraneados)
}

class LoadOrder extends Equatable {
  final String id;
  final String number;
  final String createdAt;
  final LoadOrderStatus status;
  final int totalProducts;
  final int completedProducts;
  final List<OrderLine> lines;

  const LoadOrder({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.status,
    required this.totalProducts,
    required this.completedProducts,
    required this.lines,
  });

  LoadOrder copyWith({
    String? id,
    String? number,
    String? createdAt,
    LoadOrderStatus? status,
    int? totalProducts,
    int? completedProducts,
    List<OrderLine>? lines,
  }) {
    return LoadOrder(
      id: id ?? this.id,
      number: number ?? this.number,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalProducts: totalProducts ?? this.totalProducts,
      completedProducts: completedProducts ?? this.completedProducts,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object?> get props => [
    id,
    number,
    createdAt,
    status,
    totalProducts,
    completedProducts,
    lines,
  ];
}
