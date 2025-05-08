import '../../domain/entities/product.dart';

/// Modelo de datos para el Producto
class ProductModel extends Product {
  const ProductModel({
    required String id,
    required String reference,
    required String description,
    required String barcode,
    required String location,
    required double stock,
    required String unit,
    required String status,
  }) : super(
         id: id,
         reference: reference,
         description: description,
         barcode: barcode,
         location: location,
         stock: stock,
         unit: unit,
         status: status,
       );

  /// Crea un ProductModel desde un mapa JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      reference: json['reference'],
      description: json['description'],
      barcode: json['barcode'],
      location: json['location'],
      stock: json['stock'],
      unit: json['unit'],
      status: json['status'],
    );
  }

  /// Convierte el UserModel a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'description': description,
      'barcode': barcode,
      'location': location,
      'stock': stock,
      'unit': unit,
      'status': status,
    };
  }
}
