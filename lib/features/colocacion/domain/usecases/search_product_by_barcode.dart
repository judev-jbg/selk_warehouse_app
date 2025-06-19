import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_search_result.dart';
import '../repositories/colocacion_repository.dart';

class SearchProductByBarcode
    implements UseCase<ProductSearchResult, SearchProductParams> {
  final ColocacionRepository repository;

  SearchProductByBarcode(this.repository);

  @override
  Future<Either<Failure, ProductSearchResult>> call(
      SearchProductParams params) async {
    // Validar código de barras
    if (params.barcode.trim().isEmpty) {
      return const Left(ValidationFailure('Código de barras requerido'));
    }

    // Limpiar código de barras (quitar sufijos de escáner)
    final cleanBarcode = _cleanBarcode(params.barcode);

    // Validar longitud (EAN13 o DUN14)
    if (cleanBarcode.length != 13 && cleanBarcode.length != 14) {
      return const Left(
          ValidationFailure('Código de barras debe tener 13 o 14 dígitos'));
    }

    // Buscar producto
    return await repository.searchProductByBarcode(
      cleanBarcode,
      useCache: params.useCache,
    );
  }

  /// Limpiar código de barras eliminando sufijos del escáner
  String _cleanBarcode(String barcode) {
    // Quitar sufijos comunes: \n, \t, \r y espacios
    return barcode
        .replaceAll('\n', '')
        .replaceAll('\t', '')
        .replaceAll('\r', '')
        .replaceAll(' ', '')
        .trim();
  }
}

class SearchProductParams {
  final String barcode;
  final bool useCache;

  const SearchProductParams({
    required this.barcode,
    this.useCache = true,
  });
}
