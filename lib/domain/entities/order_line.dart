import 'package:equatable/equatable.dart';
import 'product.dart';

enum OrderLineStatus {
  pending, // Pendiente (no recogido)
  completed, // Completado (recogido totalmente)
  incomplete, // Incompleto (recogido parcialmente)
  cancelled, // Cancelado
}

class OrderLine extends Equatable {
  final String id;
  final Product product;
  final double quantity;
  final double collectedQuantity;
  final String
  distributionInfo; // Formato: "6 + 4 + 2" - Indica los pedidos a los que va
  final OrderLineStatus status;
  final double volume;

  const OrderLine({
    required this.id,
    required this.product,
    required this.quantity,
    this.collectedQuantity = 0,
    required this.distributionInfo,
    required this.status,
    required this.volume,
  });

  /// Calcula la cantidad pendiente por recoger
  double get pendingQuantity => quantity - collectedQuantity;

  /// Verifica si la línea está completamente recogida
  bool get isCompleted => collectedQuantity >= quantity;

  OrderLine copyWith({
    String? id,
    Product? product,
    double? quantity,
    double? collectedQuantity,
    String? distributionInfo,
    OrderLineStatus? status,
    double? volume,
  }) {
    return OrderLine(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      collectedQuantity: collectedQuantity ?? this.collectedQuantity,
      distributionInfo: distributionInfo ?? this.distributionInfo,
      status: status ?? this.status,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [
    id,
    product,
    quantity,
    collectedQuantity,
    distributionInfo,
    status,
    volume,
  ];
}
