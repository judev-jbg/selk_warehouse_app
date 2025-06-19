import 'dart:async';
import 'package:logger/logger.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/operation_result.dart';
import '../models/product_model.dart';
import '../models/operation_result_model.dart';
import '../datasources/colocacion_local_datasource.dart';

class OptimisticUpdatesService {
  final ColocacionLocalDataSource localDataSource;
  final Logger _logger = Logger();

  // Cache de operaciones optimistas pendientes
  final Map<String, OperationResultModel> _pendingOperations = {};

  // Stream controller para notificar cambios
  final StreamController<OperationResultModel> _operationUpdatesController =
      StreamController<OperationResultModel>.broadcast();

  OptimisticUpdatesService({required this.localDataSource});

  Stream<OperationResultModel> get operationUpdates =>
      _operationUpdatesController.stream;

  /// Crear update optimista para localización
  Future<OperationResultModel> createOptimisticLocationUpdate({
    required Product originalProduct,
    required String newLocation,
    required String userId,
    required String deviceId,
  }) async {
    final operationId = _generateOperationId('location');

    // Crear producto con update optimista
    final optimisticProduct = (originalProduct as ProductModel).copyWith(
      location: newLocation,
      lastUpdated: DateTime.now(),
      isOptimistic: true,
      operationId: operationId,
    );

    // Crear resultado de operación
    final operationResult = OperationResultModel(
      operationId: operationId,
      type: OperationType.locationUpdate,
      status: OperationStatus.pending,
      product: optimisticProduct,
      message: 'Actualizando localización a $newLocation...',
      timestamp: DateTime.now(),
    );

    // Guardar en cache local con datos optimistas
    await localDataSource.cacheProduct(optimisticProduct);
    await localDataSource.saveOperationResult(operationResult);

    // Agregar a operaciones pendientes
    _pendingOperations[operationId] = operationResult;

    _logger.i('Update optimista creado para localización: $operationId');

    // Notificar cambio
    _operationUpdatesController.add(operationResult);

    return operationResult;
  }

  /// Crear update optimista para stock
  Future<OperationResultModel> createOptimisticStockUpdate({
    required Product originalProduct,
    required double newStock,
    required String userId,
    required String deviceId,
  }) async {
    final operationId = _generateOperationId('stock');

    // Crear producto con update optimista
    final optimisticProduct = (originalProduct as ProductModel).copyWith(
      qtyAvailable: newStock,
      lastUpdated: DateTime.now(),
      isOptimistic: true,
      operationId: operationId,
    );

    // Crear resultado de operación
    final operationResult = OperationResultModel(
      operationId: operationId,
      type: OperationType.stockUpdate,
      status: OperationStatus.pending,
      product: optimisticProduct,
      message: 'Actualizando stock a ${newStock.toString()}...',
      timestamp: DateTime.now(),
    );

    // Guardar en cache local con datos optimistas
    await localDataSource.cacheProduct(optimisticProduct);
    await localDataSource.saveOperationResult(operationResult);

    // Agregar a operaciones pendientes
    _pendingOperations[operationId] = operationResult;

    _logger.i('Update optimista creado para stock: $operationId');

    // Notificar cambio
    _operationUpdatesController.add(operationResult);

    return operationResult;
  }

  /// Confirmar operación optimista
  Future<void> confirmOptimisticUpdate({
    required String operationId,
    required Product confirmedProduct,
  }) async {
    final pendingOperation = _pendingOperations[operationId];
    if (pendingOperation == null) return;

    _logger.i('Confirmando update optimista: $operationId');

    // Actualizar producto con datos confirmados
    final confirmedProductModel = (confirmedProduct as ProductModel).copyWith(
      isOptimistic: false,
      operationId: null,
    );

    // Actualizar cache
    await localDataSource.cacheProduct(confirmedProductModel);

    // Actualizar estado de operación
    await localDataSource.updateOperationStatus(operationId, 'success');

    // Crear resultado confirmado
    final confirmedResult = pendingOperation.copyWith(
      status: OperationStatus.success,
      product: confirmedProductModel,
      message: _getSuccessMessage(pendingOperation.type),
    ) as OperationResultModel;

    // Remover de operaciones pendientes
    _pendingOperations.remove(operationId);

    // Notificar confirmación
    _operationUpdatesController.add(confirmedResult);
  }

  /// Revertir operación optimista (rollback)
  Future<void> rollbackOptimisticUpdate({
    required String operationId,
    required Product originalProduct,
    String? error,
  }) async {
    final pendingOperation = _pendingOperations[operationId];
    if (pendingOperation == null) return;

    _logger.w('Revirtiendo update optimista: $operationId');

    // Restaurar producto original
    final originalProductModel = originalProduct as ProductModel;
    await localDataSource.cacheProduct(originalProductModel);

    // Actualizar estado de operación
    await localDataSource.updateOperationStatus(operationId, 'failed');

    // Crear resultado fallido
    final failedResult = pendingOperation.copyWith(
      status: OperationStatus.failed,
      product: originalProductModel,
      error: error ?? 'Error en la actualización',
      message: _getErrorMessage(pendingOperation.type),
    ) as OperationResultModel;

    // Remover de operaciones pendientes
    _pendingOperations.remove(operationId);

    // Notificar fallo
    _operationUpdatesController.add(failedResult);
  }

  /// Obtener operaciones pendientes
  List<OperationResultModel> getPendingOperations() {
    return _pendingOperations.values.toList();
  }

  /// Limpiar operaciones completadas
  Future<void> cleanupCompletedOperations() async {
    final expiredTime = DateTime.now().subtract(const Duration(minutes: 5));

    _pendingOperations.removeWhere((key, operation) {
      return operation.timestamp.isBefore(expiredTime) &&
          (operation.isSuccess || operation.isFailed);
    });
  }

  /// Generar ID único para operación
  String _generateOperationId(String type) {
    return 'opt_${type}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Obtener mensaje de éxito
  String _getSuccessMessage(OperationType type) {
    switch (type) {
      case OperationType.locationUpdate:
        return 'Localización actualizada exitosamente';
      case OperationType.stockUpdate:
        return 'Stock actualizado exitosamente';
    }
  }

  /// Obtener mensaje de error
  String _getErrorMessage(OperationType type) {
    switch (type) {
      case OperationType.locationUpdate:
        return 'Error actualizando localización';
      case OperationType.stockUpdate:
        return 'Error actualizando stock';
    }
  }

  /// Cerrar servicio
  void dispose() {
    _operationUpdatesController.close();
    _pendingOperations.clear();
  }
}
