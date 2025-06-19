import '../../domain/entities/product_search_result.dart';
import 'product_model.dart';

class ProductSearchResultModel extends ProductSearchResult {
  const ProductSearchResultModel({
    required super.found,
    super.product,
    super.error,
    super.cached,
    required super.searchTime,
    required super.timestamp,
  });

  /// Crear desde respuesta del backend
  factory ProductSearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final metadata = data?['metadata'] as Map<String, dynamic>?;

    return ProductSearchResultModel(
      found: json['success'] as bool? ?? false,
      product: data?['product'] != null
          ? ProductModel.fromJson(data!['product'] as Map<String, dynamic>)
          : null,
      error: json['error'] as String?,
      cached: metadata?['cached'] as bool? ?? false,
      searchTime: metadata?['searchTime'] as int? ?? 0,
      timestamp: metadata?['timestamp'] != null
          ? DateTime.parse(metadata!['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Crear desde respuesta de error
  factory ProductSearchResultModel.fromError(String error) {
    return ProductSearchResultModel(
      found: false,
      error: error,
      searchTime: 0,
      timestamp: DateTime.now(),
    );
  }

  /// Crear resultado exitoso
  factory ProductSearchResultModel.success({
    required ProductModel product,
    bool cached = false,
    int searchTime = 0,
  }) {
    return ProductSearchResultModel(
      found: true,
      product: product,
      cached: cached,
      searchTime: searchTime,
      timestamp: DateTime.now(),
    );
  }
}
