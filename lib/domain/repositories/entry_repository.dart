import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/product.dart';
import '../entities/scan.dart';
import '../entities/delivery_note.dart';
import '../entities/supplier.dart';
import '../entities/order.dart' as ord;

abstract class EntryRepository {
  /// Busca un producto por su código de barras y verifica si está en un pedido pendiente
  ///
  /// Retorna un [Product] si lo encuentra o un [Failure] si ocurre un error
  Future<Either<Failure, Product>> findProductByBarcode(String barcode);

  /// Registra una lectura de producto
  ///
  /// Retorna un [Scan] si la operación es exitosa o un [Failure] si ocurre un error
  Future<Either<Failure, Scan>> registerScan(
    String barcode, {
    String? orderId,
    String? supplierId,
  });

  /// Obtiene todas las lecturas registradas
  ///
  /// Retorna una lista de [Scan] si la operación es exitosa o un [Failure] si ocurre un error
  Future<Either<Failure, List<Scan>>> getAllScans();

  /// Actualiza la cantidad de una lectura
  ///
  /// Retorna un [Scan] actualizado si la operación es exitosa o un [Failure] si ocurre un error
  Future<Either<Failure, Scan>> updateScanQuantity(
    String scanId,
    double newQuantity,
  );

  /// Elimina una lectura
  ///
  /// Retorna void si la operación es exitosa o un [Failure] si ocurre un error
  Future<Either<Failure, void>> deleteScan(String scanId);

  /// Obtiene todos los proveedores
  ///
  /// Retorna una lista de [Supplier] si la operación es exitosa o un [Failure] si ocurre un error
  Future<Either<Failure, List<Supplier>>> getAllSuppliers();

  /// Obtiene todos los pedidos pendientes
  ///
  /// Retorna una lista de [ord.Order] si la operación es exitosa o un [Failure] si ocurre un error
  Future<Either<Failure, List<ord.Order>>> getPendingOrders({
    String? supplierId,
  });

  /// Genera un albarán de entrada
  ///
  /// Retorna un [DeliveryNote] si la operación es exitosa o un [Failure] si ocurre un error
  Future<Either<Failure, DeliveryNote>> generateDeliveryNote(
    String supplierReference,
    List<String> scanIds,
  );

  /// Busca productos "9999" por referencia o descripción
  ///
  /// Retorna una lista de [Product] si la operación es exitosa o un [Failure] si ocurre un error
  Future<Either<Failure, List<Product>>> searchSpecialProducts(String query);
}
