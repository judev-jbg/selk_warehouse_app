import '../../domain/entities/scan.dart';
import '../../domain/entities/product.dart';

/// Modelo de datos para el Producto
class ScanModel extends Scan {
  const ScanModel({
    required String id,
    required Product product,
    required double quantity,
    required String createdAt,
    required String? orderId,
    required String? supplierId,
  }) : super(
         id: id,
         product: product,
         quantity: quantity,
         createdAt: createdAt,
         orderId: orderId,
         supplierId: supplierId,
       );

  /// Crea un ScanModel desde un mapa JSON
  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'],
      product: json['product'],
      quantity: json['quantity'],
      createdAt: json['createdAt'],
      orderId: json['orderId'],
      supplierId: json['supplierId'],
    );
  }

  /// Crea un ScanModel desde los datos de una consulta a la base de datos
  factory ScanModel.fromDatabaseQuery(Map<String, dynamic> data) {
    return ScanModel(
      id: data['id'].toString(), // Asegurando que sea String
      product:
          data['product'], // Acepta Product directo o lo construye desde JSON
      quantity:
          data['quantity'] is double
              ? data['quantity']
              : (data['quantity'] as int)
                  .toDouble(), // Convierte int a double si es necesario
      createdAt:
          data['created_at'] ??
          DateTime.now().toString(), // Usa valor o fecha actual
      orderId: data['order_id']?.toString(),
      supplierId: data['supplier_id']?.toString(),
    );
  }

  /// Convierte el ScanModel a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'quantity': quantity,
      'createdAt': createdAt,
      'orderId': orderId,
      'supplierId': supplierId,
    };
  }
}
