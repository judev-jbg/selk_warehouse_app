import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_search_result.dart';
import '../repositories/colocacion_repository.dart';
import '../../data/services/barcode_processor.dart';

class SearchProductByBarcode
    implements UseCase<ProductSearchResult, SearchProductParams> {
  final ColocacionRepository repository;

  SearchProductByBarcode(this.repository);

  @override
  Future<Either<Failure, ProductSearchResult>> call(
      SearchProductParams params) async {
    // Procesar código de barras con el BarcodeProcessor mejorado
    final processResult =
        BarcodeProcessor.processScannedBarcode(params.barcode);

    if (!processResult.isSuccess) {
      return Left(ValidationFailure(
          processResult.error ?? 'Código de barras inválido'));
    }

    final cleanBarcode = processResult.cleanedBarcode!;

    // Validar que el tipo de código sea soportado
    if (!processResult.barcodeType!.isSupported) {
      return Left(ValidationFailure(
          'Tipo de código no soportado: ${processResult.barcodeType!.displayName}\n'
          'Solo se permiten códigos EAN-13 y DUN-14'));
    }

    // Advertir si el checksum no es válido pero continuar
    if (!processResult.isValidChecksum &&
        processResult.validationMessage != null) {
      // Log warning pero continuar con la búsqueda
      print('⚠️ Warning: ${processResult.validationMessage}');
    }

    // Buscar producto
    return await repository.searchProductByBarcode(
      cleanBarcode,
      useCache: params.useCache,
    );
  }
}

class SearchProductParams {
  final String barcode;
  final bool useCache;

  const SearchProductParams({
    required this.barcode,
    this.useCache = true,
  });

  /// Crear parámetros con información de procesamiento
  factory SearchProductParams.fromProcessedBarcode({
    required BarcodeProcessResult processResult,
    bool useCache = true,
  }) {
    return SearchProductParams(
      barcode: processResult.cleanedBarcode!,
      useCache: useCache,
    );
  }
}
