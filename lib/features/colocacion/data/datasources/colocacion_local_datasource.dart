import 'package:selk_warehouse_app/features/colocacion/domain/entities/operation_result.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';
import '../models/operation_result_model.dart';

abstract class ColocacionLocalDataSource {
  Future<ProductModel?> getCachedProduct(String barcode);
  Future<void> cacheProduct(ProductModel product);
  Future<void> clearProductCache();
  Future<void> saveOperationResult(OperationResultModel operation);
  Future<List<OperationResultModel>> getPendingOperations();
  Future<void> updateOperationStatus(String operationId, String status);
  Future<void> cleanExpiredCache();
}

class ColocacionLocalDataSourceImpl implements ColocacionLocalDataSource {
  final DatabaseHelper databaseHelper;

  ColocacionLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<ProductModel?> getCachedProduct(String barcode) async {
    try {
      final db = await databaseHelper.database;

      final result = await db.query(
        'cached_products',
        where: 'barcode = ? AND cached_at > ?',
        whereArgs: [
          barcode,
          DateTime.now()
              .subtract(const Duration(minutes: 30))
              .toIso8601String(),
        ],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return ProductModel.fromDatabase(result.first);
      }
      return null;
    } catch (e) {
      throw CacheException(
          'Error obteniendo producto desde cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    try {
      final db = await databaseHelper.database;

      await db.insert(
        'cached_products',
        product.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(
          'Error guardando producto en cache: ${e.toString()}');
    }
  }

  @override
  Future<void> clearProductCache() async {
    try {
      final db = await databaseHelper.database;
      await db.delete('cached_products');
    } catch (e) {
      throw CacheException('Error limpiando cache: ${e.toString()}');
    }
  }

  @override
  Future<void> saveOperationResult(OperationResultModel operation) async {
    try {
      final db = await databaseHelper.database;

      final operationMap = {
        'operation_id': operation.operationId,
        'type': operation.type.name,
        'status': operation.status.name,
        'product_id': operation.product?.id,
        'message': operation.message,
        'timestamp': operation.timestamp.toIso8601String(),
        'error': operation.error,
        'created_at': DateTime.now().toIso8601String(),
      };

      await db.insert(
        'operations',
        operationMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Error guardando operación: ${e.toString()}');
    }
  }

  @override
  Future<List<OperationResultModel>> getPendingOperations() async {
    try {
      final db = await databaseHelper.database;

      final result = await db.query(
        'operations',
        where: 'status = ?',
        whereArgs: ['pending'],
        orderBy: 'timestamp DESC',
      );

      return result.map((row) => _operationFromDatabase(row)).toList();
    } catch (e) {
      throw CacheException(
          'Error obteniendo operaciones pendientes: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOperationStatus(String operationId, String status) async {
    try {
      final db = await databaseHelper.database;

      await db.update(
        'operations',
        {
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'operation_id = ?',
        whereArgs: [operationId],
      );
    } catch (e) {
      throw CacheException('Error actualizando operación: ${e.toString()}');
    }
  }

  @override
  Future<void> cleanExpiredCache() async {
    try {
      final db = await databaseHelper.database;
      final expiredTime = DateTime.now().subtract(const Duration(hours: 2));

      // Limpiar productos en cache expirados
      await db.delete(
        'cached_products',
        where: 'cached_at < ?',
        whereArgs: [expiredTime.toIso8601String()],
      );

      // Limpiar operaciones antiguas completadas
      await db.delete(
        'operations',
        where: 'status IN (?, ?) AND created_at < ?',
        whereArgs: [
          'success',
          'failed',
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        ],
      );
    } catch (e) {
      throw CacheException('Error limpiando cache expirado: ${e.toString()}');
    }
  }

  /// Crear OperationResultModel desde base de datos
  OperationResultModel _operationFromDatabase(Map<String, dynamic> row) {
    return OperationResultModel(
      operationId: row['operation_id'] as String,
      type: row['type'] == 'locationUpdate'
          ? OperationType.locationUpdate
          : OperationType.stockUpdate,
      status: _parseStatus(row['status'] as String),
      message: row['message'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      error: row['error'] as String?,
    );
  }

  OperationStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return OperationStatus.pending;
      case 'success':
        return OperationStatus.success;
      case 'failed':
        return OperationStatus.failed;
      case 'rolledBack':
        return OperationStatus.rolledBack;
      default:
        return OperationStatus.pending;
    }
  }
}
