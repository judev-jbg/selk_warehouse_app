// lib/features/colocacion/data/models/label_model.dart
import '../../domain/entities/label.dart';
import '../../domain/entities/product.dart';
import 'product_model.dart';

class LabelModel extends Label {
  const LabelModel({
    required super.id,
    required super.product,
    required super.location,
    required super.createdAt,
    required super.updatedAt,
    super.isPrinted,
    super.status,
  });

  /// Crear desde JSON del backend
  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      location: json['location'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isPrinted: json['is_printed'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
    );
  }

  /// Convertir a JSON para API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': (product as ProductModel).toJson(),
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_printed': isPrinted,
      'status': status,
    };
  }

  /// Crear desde base de datos SQLite
  factory LabelModel.fromDatabase(Map<String, dynamic> dbRow) {
    return LabelModel(
      id: dbRow['id'] as String,
      product: ProductModel.fromDatabase({
        'id': dbRow['product_id'],
        'name': dbRow['product_name'],
        'default_code': dbRow['product_default_code'],
        'barcode': dbRow['product_barcode'],
        'qty_available': dbRow['product_qty_available'],
        'location': dbRow['location'],
        'active': dbRow['product_active'],
        'categ_id': dbRow['product_categ_id'],
        'list_price': dbRow['product_list_price'],
        'standard_price': dbRow['product_standard_price'],
        'uom_name': dbRow['product_uom_name'],
        'company_id': dbRow['product_company_id'],
        'last_updated': dbRow['product_last_updated'],
        'is_optimistic': dbRow['product_is_optimistic'] ?? 0,
        'operation_id': dbRow['product_operation_id'],
        'cached_at':
            dbRow['product_cached_at'] ?? DateTime.now().toIso8601String(),
      }),
      location: dbRow['location'] as String,
      createdAt: DateTime.parse(dbRow['created_at'] as String),
      updatedAt: DateTime.parse(dbRow['updated_at'] as String),
      isPrinted: (dbRow['is_printed'] as int) == 1,
      status: dbRow['status'] as String,
    );
  }

  /// Convertir para base de datos SQLite
  Map<String, dynamic> toDatabaseMap() {
    final productModel = product as ProductModel;
    return {
      'id': id,
      'product_id': productModel.id,
      'product_name': productModel.name,
      'product_default_code': productModel.defaultCode,
      'product_barcode': productModel.barcode,
      'product_qty_available': productModel.qtyAvailable,
      'location': location,
      'product_active': productModel.active ? 1 : 0,
      'product_categ_id': productModel.categoryId,
      'product_list_price': productModel.listPrice,
      'product_standard_price': productModel.standardPrice,
      'product_uom_name': productModel.uomName,
      'product_company_id': productModel.companyId,
      'product_last_updated': productModel.lastUpdated.toIso8601String(),
      'product_is_optimistic': productModel.isOptimistic ? 1 : 0,
      'product_operation_id': productModel.operationId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_printed': isPrinted ? 1 : 0,
      'status': status,
    };
  }

  /// Crear desde entidad de dominio
  factory LabelModel.fromEntity(Label label) {
    return LabelModel(
      id: label.id,
      product: label.product,
      location: label.location,
      createdAt: label.createdAt,
      updatedAt: label.updatedAt,
      isPrinted: label.isPrinted,
      status: label.status,
    );
  }

  @override
  LabelModel copyWith({
    String? id,
    Product? product,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPrinted,
    String? status,
  }) {
    return LabelModel(
      id: id ?? this.id,
      product: product ?? this.product,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPrinted: isPrinted ?? this.isPrinted,
      status: status ?? this.status,
    );
  }
}
