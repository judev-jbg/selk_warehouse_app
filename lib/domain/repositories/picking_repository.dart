import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/load_order.dart';
import '../entities/order_line.dart';
import '../entities/customer_delivery_note.dart';

abstract class PickingRepository {
  /// Obtiene todas las órdenes de carga según su estado
  ///
  /// Retorna una lista de [LoadOrder] si la operación es exitosa
  /// o un [Failure] si ocurre un error
  Future<Either<Failure, List<LoadOrder>>> getLoadOrders({
    LoadOrderStatus? status,
  });

  /// Obtiene el detalle de una orden de carga
  ///
  /// Retorna un [LoadOrder] si la operación es exitosa
  /// o un [Failure] si ocurre un error
  Future<Either<Failure, LoadOrder>> getLoadOrderDetail(String loadOrderId);

  /// Inicia el proceso de recogida de una orden de carga
  ///
  /// Retorna un [LoadOrder] actualizado si la operación es exitosa
  /// o un [Failure] si ocurre un error
  Future<Either<Failure, LoadOrder>> startPickingProcess(String loadOrderId);

  /// Registra la recogida de un producto
  ///
  /// Retorna una [OrderLine] actualizada si la operación es exitosa
  /// o un [Failure] si ocurre un error
  Future<Either<Failure, OrderLine>> registerProductPicking(
    String loadOrderId,
    String orderLineId,
    double quantity, {
    bool forceIncomplete = false,
  });

  /// Obtiene todas las líneas recogidas de una orden de carga
  ///
  /// Retorna una lista de [OrderLine] si la operación es exitosa
  /// o un [Failure] si ocurre un error
  Future<Either<Failure, List<OrderLine>>> getPickedItems(String loadOrderId);

  /// Genera albaranes de cliente basado en las líneas recogidas
  ///
  /// Retorna una lista de [CustomerDeliveryNote] si la operación es exitosa
  /// o un [Failure] si ocurre un error
  Future<Either<Failure, List<CustomerDeliveryNote>>>
  generateCustomerDeliveryNotes(String loadOrderId);
}
