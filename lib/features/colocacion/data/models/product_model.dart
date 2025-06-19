import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.defaultCode,
    required super.barcode,
    required super.qtyAvailable,
    super.location,
    required super.active,
    required super.categoryId,
    required super.listPrice,
    required super.standardPrice,
    required super.uomName,
    required super.companyId,
    required super.lastUpdated,
    super.isOptimistic,
    super.operationId,
  });

  /// Crear desde JSON del backend
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      defaultCode: json['default_code'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      qtyAvailable: (json['qty_available'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String?,
      active: json['active'] as bool? ?? true,
      categoryId: json['categ_id'] as int? ?? 0,
      listPrice: (json['list_price'] as num?)?.toDouble() ?? 0.0,
      standardPrice: (json['standard_price'] as num?)?.toDouble() ?? 0.0,
      uomName: json['uom_name'] as String? ?? 'Unidad',
      companyId: json['company_id'] as int? ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
      isOptimistic: json['_optimistic'] as bool? ?? false,
      operationId: json['_operationId'] as String?,
    );
  }

  /// Convertir a JSON para cache local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'default_code': defaultCode,
      'barcode': barcode,
      'qty_available': qtyAvailable,
      'location': location,
      'active': active,
      'categ_id': categoryId,
      'list_price': listPrice,
      'standard_price': standardPrice,
      'uom_name': uomName,
      'company_id': companyId,
      'last_updated': lastUpdated.toIso8601String(),
      '_optimistic': isOptimistic,
      '_operationId': operationId,
    };
  }

  /// Crear desde base de datos SQLite
  factory ProductModel.fromDatabase(Map<String, dynamic> dbRow) {
    return ProductModel(
      id: dbRow['id'] as int,
      name: dbRow['name'] as String,
      defaultCode: dbRow['default_code'] as String,
      barcode: dbRow['barcode'] as String,
      qtyAvailable: dbRow['qty_available'] as double,
      location: dbRow['location'] as String?,
      active: (dbRow['active'] as int) == 1,
      categoryId: dbRow['categ_id'] as int,
      listPrice: dbRow['list_price'] as double,
      standardPrice: dbRow['standard_price'] as double,
      uomName: dbRow['uom_name'] as String,
      companyId: dbRow['company_id'] as int,
      lastUpdated: DateTime.parse(dbRow['last_updated'] as String),
      isOptimistic: (dbRow['is_optimistic'] as int?) == 1,
      operationId: dbRow['operation_id'] as String?,
    );
  }

  /// Convertir para base de datos SQLite
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'default_code': defaultCode,
      'barcode': barcode,
      'qty_available': qtyAvailable,
      'location': location,
      'active': active ? 1 : 0,
      'categ_id': categoryId,
      'list_price': listPrice,
      'standard_price': standardPrice,
      'uom_name': uomName,
      'company_id': companyId,
      'last_updated': lastUpdated.toIso8601String(),
      'is_optimistic': isOptimistic ? 1 : 0,
      'operation_id': operationId,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  /// Crear desde entidad de dominio
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      defaultCode: product.defaultCode,
      barcode: product.barcode,
      qtyAvailable: product.qtyAvailable,
      location: product.location,
      active: product.active,
      categoryId: product.categoryId,
      listPrice: product.listPrice,
      standardPrice: product.standardPrice,
      uomName: product.uomName,
      companyId: product.companyId,
      lastUpdated: product.lastUpdated,
      isOptimistic: product.isOptimistic,
      operationId: product.operationId,
    );
  }

  @override
  ProductModel copyWith({
    int? id,
    String? name,
    String? defaultCode,
    String? barcode,
    double? qtyAvailable,
    String? location,
    bool? active,
    int? categoryId,
    double? listPrice,
    double? standardPrice,
    String? uomName,
    int? companyId,
    DateTime? lastUpdated,
    bool? isOptimistic,
    String? operationId,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultCode: defaultCode ?? this.defaultCode,
      barcode: barcode ?? this.barcode,
      qtyAvailable: qtyAvailable ?? this.qtyAvailable,
      location: location ?? this.location,
      active: active ?? this.active,
      categoryId: categoryId ?? this.categoryId,
      listPrice: listPrice ?? this.listPrice,
      standardPrice: standardPrice ?? this.standardPrice,
      uomName: uomName ?? this.uomName,
      companyId: companyId ?? this.companyId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOptimistic: isOptimistic ?? this.isOptimistic,
      operationId: operationId ?? this.operationId,
    );
  }
}
