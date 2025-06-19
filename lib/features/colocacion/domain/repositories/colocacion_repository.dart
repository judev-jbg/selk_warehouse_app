import 'package:dartz/dartz.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/entities/label.dart';
import '../../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../entities/product_search_result.dart';
import '../entities/operation_result.dart';

abstract class ColocacionRepository {
  /// Buscar producto por código de barras
  Future<Either<Failure, ProductSearchResult>> searchProductByBarcode(
    String barcode, {
    bool useCache = true,
  });

  /// Actualizar localización de producto
  Future<Either<Failure, OperationResult>> updateProductLocation(
    int productId,
    String newLocation,
  );

  /// Actualizar stock de producto
  Future<Either<Failure, OperationResult>> updateProductStock(
    int productId,
    double newStock,
  );

  /// Obtener producto desde cache local
  Future<Either<Failure, Product>> getCachedProduct(String barcode);

  /// Guardar producto en cache local
  Future<Either<Failure, void>> cacheProduct(Product product);

  /// Obtener operaciones pendientes
  Future<Either<Failure, List<OperationResult>>> getPendingOperations();

  /// Obtener estado de operación específica
  Future<Either<Failure, OperationResult>> getOperationStatus(
      String operationId);

  /// Limpiar cache de productos
  Future<Either<Failure, void>> clearProductCache();

  /// Verificar conectividad con el servidor
  Future<bool> isServerReachable();

  /// Crear etiqueta para impresión
  Future<Either<Failure, Label>> createLabel(Product product, String location);

  /// Obtener etiquetas pendientes
  Future<Either<Failure, List<Label>>> getPendingLabels();

  /// Marcar etiquetas como impresas
  Future<Either<Failure, void>> markLabelsAsPrinted(List<String> labelIds);

  /// Eliminar etiquetas
  Future<Either<Failure, void>> deleteLabels(List<String> labelIds);

  /// Obtener historial de etiquetas
  Future<Either<Failure, List<Label>>> getLabelHistory({int limit = 50});
}
