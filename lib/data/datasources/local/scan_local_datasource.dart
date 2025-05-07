import 'package:uuid/uuid.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/scan_model.dart';
import 'database_helper.dart';

abstract class ScanLocalDataSource {
  /// Registra una nueva lectura
  ///
  /// Lanza [CacheException] si ocurre un error
  Future<ScanModel> registerScan(
    String productId,
    double quantity, {
    String? orderId,
    String? supplierId,
  });

  /// Obtiene todas las lecturas
  ///
  /// Lanza [CacheException] si ocurre un error
  Future<List<ScanModel>> getAllScans();

  /// Actualiza la cantidad de una lectura
  ///
  /// Lanza [CacheException] si ocurre un error
  Future<void> updateScanQuantity(String scanId, double quantity);

  /// Elimina una lectura
  ///
  /// Lanza [CacheException] si ocurre un error
  Future<void> deleteScan(String scanId);
}

class ScanLocalDataSourceImpl implements ScanLocalDataSource {
  final DatabaseHelper dbHelper;
  final uuid = Uuid();

  ScanLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<ScanModel> registerScan(
    String productId,
    double quantity, {
    String? orderId,
    String? supplierId,
  }) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final scanId = uuid.v4();

    try {
      await db.insert(StorageConstants.scansTable, {
        'id': scanId,
        'product_id': productId,
        'quantity': quantity,
        'created_at': now,
        'order_id': orderId,
        'supplier_id': supplierId,
        'synced': 0,
      });

      // Obtener el producto asociado a la lectura
      final productResult = await db.query(
        StorageConstants.productsTable,
        where: 'id = ?',
        whereArgs: [productId],
      );

      if (productResult.isEmpty) {
        throw CacheException('Producto no encontrado');
      }

      // Crear el modelo de la lectura
      return ScanModel.fromDatabaseQuery({
        'id': scanId,
        'product_id': productId,
        'quantity': quantity,
        'created_at': now,
        'order_id': orderId,
        'supplier_id': supplierId,
        'synced': 0,
        'product': productResult.first,
      });
    } catch (e) {
      throw CacheException('Error al registrar la lectura: $e');
    }
  }

  @override
  Future<List<ScanModel>> getAllScans() async {
    final db = await dbHelper.database;

    try {
      // Obtener todas las lecturas con sus productos asociados mediante JOIN
      final result = await db.rawQuery('''
        SELECT s.*, p.*
        FROM ${StorageConstants.scansTable} s
        INNER JOIN ${StorageConstants.productsTable} p ON s.product_id = p.id
        ORDER BY s.created_at DESC
      ''');

      return result.map((row) => ScanModel.fromDatabaseQuery(row)).toList();
    } catch (e) {
      throw CacheException('Error al obtener las lecturas: $e');
    }
  }

  @override
  Future<void> updateScanQuantity(String scanId, double quantity) async {
    final db = await dbHelper.database;

    try {
      final count = await db.update(
        StorageConstants.scansTable,
        {
          'quantity': quantity,
          'synced': 0, // Marcar como no sincronizado
        },
        where: 'id = ?',
        whereArgs: [scanId],
      );

      if (count == 0) {
        throw CacheException('No se pudo actualizar la lectura');
      }
    } catch (e) {
      throw CacheException('Error al actualizar la lectura: $e');
    }
  }

  @override
  Future<void> deleteScan(String scanId) async {
    final db = await dbHelper.database;

    try {
      final count = await db.delete(
        StorageConstants.scansTable,
        where: 'id = ?',
        whereArgs: [scanId],
      );

      if (count == 0) {
        throw CacheException('No se pudo eliminar la lectura');
      }
    } catch (e) {
      throw CacheException('Error al eliminar la lectura: $e');
    }
  }
}
