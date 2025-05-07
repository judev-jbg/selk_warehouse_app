import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/storage_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, StorageConstants.dbName);

    return await openDatabase(
      path,
      version: StorageConstants.dbVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        name TEXT NOT NULL,
        roles TEXT NOT NULL,
        token TEXT NOT NULL,
        refresh_token TEXT
      )
    ''');

    // Tabla de productos
    await db.execute('''
      CREATE TABLE ${StorageConstants.productsTable} (
        id TEXT PRIMARY KEY,
        reference TEXT NOT NULL,
        description TEXT NOT NULL,
        barcode TEXT NOT NULL,
        location TEXT NOT NULL,
        stock REAL NOT NULL,
        unit TEXT NOT NULL,
        status TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tabla de lecturas
    await db.execute('''
      CREATE TABLE ${StorageConstants.scansTable} (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        created_at TEXT NOT NULL,
        order_id TEXT,
        supplier_id TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES ${StorageConstants.productsTable} (id)
      )
    ''');

    // Tabla de etiquetas
    await db.execute('''
      CREATE TABLE ${StorageConstants.labelsTable} (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        printed INTEGER DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES ${StorageConstants.productsTable} (id)
      )
    ''');

    // Tabla de albaranes
    await db.execute('''
      CREATE TABLE ${StorageConstants.deliveryNotesTable} (
        id TEXT PRIMARY KEY,
        number TEXT NOT NULL,
        supplier_id TEXT,
        customer_id TEXT,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Lógica para actualizaciones futuras de la estructura de la base de datos
    if (oldVersion < 2) {
      // Ejemplo: Agregar una nueva columna a una tabla existente
      // await db.execute('ALTER TABLE ${StorageConstants.productsTable} ADD COLUMN new_column TEXT');
    }
  }

  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, StorageConstants.dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
