import '../../domain/entities/scan.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/supplier.dart';
import 'product_model.dart';
import 'supplier_model.dart';

class ScanModel extends Scan {
  const ScanModel({
    required String id,
    required Product product,
    required double quantity,
    required String createdAt,
    String? orderId,
    Supplier? supplier,
    String? userId,
    bool synced = false,
  }) : super(
         id: id,
         product: product,
         quantity: quantity,
         createdAt: createdAt,
         orderId: orderId,
         supplier: supplier,
         userId: userId,
         synced: synced,
       );

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'],
      product: ProductModel.fromJson(json['product']),
      quantity:
          json['quantity'] is int
              ? (json['quantity'] as int).toDouble()
              : json['quantity'],
      createdAt: json['created_at'],
      orderId: json['order_id'],
      supplier:
          json['supplier'] != null
              ? SupplierModel.fromJson(json['supplier'])
              : null,
      userId: json['user_id'],
      synced: json['synced'] ?? false,
    );
  }

  factory ScanModel.fromDatabaseQuery(Map<String, dynamic> row) {
    final productJson = {
      'id': row['product_id'],
      'reference': row['reference'],
      'description': row['description'],
      'barcode': row['barcode'],
      'location': row['location'],
      'stock': row['stock'],
      'unit': row['unit'],
      'status': row['status'],
    };

    return ScanModel(
      id: row['id'],
      product: ProductModel.fromJson(productJson),
      quantity:
          row['quantity'] is int
              ? (row['quantity'] as int).toDouble()
              : row['quantity'],
      createdAt: row['created_at'],
      orderId: row['order_id'],
      supplier: null, // Se obtendría en una consulta adicional
      userId: row['user_id'],
      synced: row['synced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    final productModel =
        product is ProductModel
            ? product as ProductModel
            : ProductModel.fromEntity(product);

    final supplierModel =
        supplier != null
            ? supplier is SupplierModel
                ? supplier as SupplierModel
                : SupplierModel.fromEntity(supplier!)
            : null;

    return {
      'id': id,
      'product': productModel.toJson(),
      'quantity': quantity,
      'created_at': createdAt,
      'order_id': orderId,
      'supplier': supplierModel?.toJson(),
      'user_id': userId,
      'synced': synced,
    };
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'product_id': product.id,
      'quantity': quantity,
      'created_at': createdAt,
      'order_id': orderId,
      'supplier_id': supplier?.id,
      'user_id': userId,
      'synced': synced ? 1 : 0,
    };
  }

  factory ScanModel.fromEntity(Scan scan) {
    return ScanModel(
      id: scan.id,
      product: scan.product,
      quantity: scan.quantity,
      createdAt: scan.createdAt,
      orderId: scan.orderId,
      supplier: scan.supplier,
      userId: scan.userId,
      synced: scan.synced,
    );
  }
}
