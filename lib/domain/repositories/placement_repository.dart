import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product.dart';
import '../entities/label.dart';

abstract class PlacementRepository {
  /// Busca un producto por código de barras
  ///
  /// Retorna un [Product] si la búsqueda es exitosa o
  /// un [Failure] si ocurre un error
  Future<Either<Failure, Product>> searchProductByBarcode(String barcode);

  /// Actualiza la ubicación de un producto
  ///
  /// Retorna un [Product] actualizado si la operación es exitosa o
  /// un [Failure] si ocurre un error
  Future<Either<Failure, Product>> updateProductLocation(
    String productId,
    String newLocation,
  );

  /// Actualiza el stock de un producto
  ///
  /// Retorna un [Product] actualizado si la operación es exitosa o
  /// un [Failure] si ocurre un error
  Future<Either<Failure, Product>> updateProductStock(
    String productId,
    double newStock,
  );

  /// Obtiene todas las etiquetas pendientes de impresión
  ///
  /// Retorna una lista de [Label] si la operación es exitosa o
  /// un [Failure] si ocurre un error
  Future<Either<Failure, List<Label>>> getPendingLabels();

  /// Imprime etiquetas seleccionadas
  ///
  /// Retorna una lista de [Label] impresas si la operación es exitosa o
  /// un [Failure] si ocurre un error
  Future<Either<Failure, List<Label>>> printLabels(List<String> labelIds);

  /// Elimina una etiqueta
  ///
  /// Retorna void si la operación es exitosa o
  /// un [Failure] si ocurre un error
  Future<Either<Failure, void>> deleteLabel(String labelId);
}
