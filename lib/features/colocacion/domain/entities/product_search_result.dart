// lib/features/colocacion/domain/entities/product_search_result.dart - NUEVO ARCHIVO
import 'package:equatable/equatable.dart';
import 'product.dart';

class ProductSearchResult extends Equatable {
  final bool found;
  final Product? product;
  final String? error;
  final bool cached;
  final int searchTime;
  final DateTime timestamp;

  const ProductSearchResult({
    required this.found,
    this.product,
    this.error,
    this.cached = false,
    required this.searchTime,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        found,
        product,
        error,
        cached,
        searchTime,
        timestamp,
      ];

  ProductSearchResult copyWith({
    bool? found,
    Product? product,
    String? error,
    bool? cached,
    int? searchTime,
    DateTime? timestamp,
  }) {
    return ProductSearchResult(
      found: found ?? this.found,
      product: product ?? this.product,
      error: error ?? this.error,
      cached: cached ?? this.cached,
      searchTime: searchTime ?? this.searchTime,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
