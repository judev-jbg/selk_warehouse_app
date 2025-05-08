import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/product_model.dart';
import 'database_helper.dart';

abstract class ProductLocalDataSource {
  /// Obtiene un producto por su código de barras
  ///
  /// Lanza [CacheException] si no se encuentra
  Future<ProductModel> getProductByBarcode(String barcode);

  /// Actualiza la ubicación de un producto
  ///
  /// Lanza [CacheException] si ocurre un error
  Future<void> updateProductLocation(String productId, String location);

  /// Actualiza el stock de un producto
  ///
  /// Lanza [CacheException] si ocurre un error
  Future<void> updateProductStock(String productId, double stock);

  /// Guarda un producto en la base de datos local
  ///
  /// Lanza [CacheException] si ocurre un error
  Future<void> cacheProduct(ProductModel product);

  /// Obtiene todos los productos
  ///
  /// Lanza [CacheException] si ocurre un error
  Future<List<ProductModel>> getAllProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final DatabaseHelper dbHelper;
  final uuid = Uuid();

  ProductLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<ProductModel> getProductByBarcode(String barcode) async {
    final db = await dbHelper.database;
    final result = await db.query(
      StorageConstants.productsTable,
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (result.isNotEmpty) {
      return ProductModel.fromJson(result.first);
    } else {
      throw CacheException('Producto no encontrado');
    }
  }

  @override
  Future<void> updateProductLocation(String productId, String location) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final count = await db.update(
      StorageConstants.productsTable,
      {'location': location, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [productId],
    );

    if (count == 0) {
      throw CacheException('No se pudo actualizar la ubicación del producto');
    }

    // Crear una etiqueta para el producto
    await db.insert(StorageConstants.labelsTable, {
      'id': uuid.v4(),
      'product_id': productId,
      'created_at': now,
      'printed': 0,
    });
  }

  @override
  Future<void> updateProductStock(String productId, double stock) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final count = await db.update(
      StorageConstants.productsTable,
      {'stock': stock, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [productId],
    );

    if (count == 0) {
      throw CacheException('No se pudo actualizar el stock del producto');
    }
  }

  @override
  Future<void> cacheProduct(ProductModel product) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    try {
      await db.insert(
        StorageConstants.productsTable,
        {
          'id': product.id,
          'reference': product.reference,
          'description': product.description,
          'barcode': product.barcode,
          'location': product.location,
          'stock': product.stock,
          'unit': product.unit,
          'status': product.status,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Error al guardar el producto: $e');
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final db = await dbHelper.database;
    final result = await db.query(StorageConstants.productsTable);

    return result.map((json) => ProductModel.fromJson(json)).toList();
  }
}
