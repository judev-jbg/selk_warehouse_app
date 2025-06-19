import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String defaultCode;
  final String barcode;
  final double qtyAvailable;
  final String? location;
  final bool active;
  final int categoryId;
  final double listPrice;
  final double standardPrice;
  final String uomName;
  final int companyId;
  final DateTime lastUpdated;
  final bool isOptimistic;
  final String? operationId;

  const Product({
    required this.id,
    required this.name,
    required this.defaultCode,
    required this.barcode,
    required this.qtyAvailable,
    this.location,
    required this.active,
    required this.categoryId,
    required this.listPrice,
    required this.standardPrice,
    required this.uomName,
    required this.companyId,
    required this.lastUpdated,
    this.isOptimistic = false,
    this.operationId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        defaultCode,
        barcode,
        qtyAvailable,
        location,
        active,
        categoryId,
        listPrice,
        standardPrice,
        uomName,
        companyId,
        lastUpdated,
        isOptimistic,
        operationId,
      ];

  Product copyWith({
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
    return Product(
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

  /// Getters de conveniencia
  String get formattedStock {
    if (qtyAvailable == qtyAvailable.truncateToDouble()) {
      return qtyAvailable.toInt().toString();
    }
    return qtyAvailable.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  String get displayLocation => location ?? 'Sin ubicación';

  bool get hasLocation => location != null && location!.isNotEmpty;

  bool get hasStock => qtyAvailable > 0;

  String get statusText => active ? 'Activo' : 'Inactivo';
}
