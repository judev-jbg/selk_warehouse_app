// lib/core/storage/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;
  final Logger _logger = Logger();

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConstants.databaseName);

      _logger.i('Inicializando base de datos en: $path');

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      _logger.e('Error inicializando base de datos: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      _logger.i('Creando tablas de base de datos');

      // Tabla de usuarios (caché)
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          odoo_user_id INTEGER NOT NULL,
          username TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL,
          full_name TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          permissions TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          last_sync TEXT
        )
      ''');

      // Tabla de sesiones (para manejo offline)
      await db.execute('''
        CREATE TABLE sessions (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          device_identifier TEXT NOT NULL,
          access_token TEXT,
          refresh_token TEXT,
          expires_at TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          last_activity TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      // Tabla de logs de auditoría local
      await db.execute('''
        CREATE TABLE audit_logs (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          action TEXT NOT NULL,
          module TEXT,
          device_identifier TEXT NOT NULL,
          metadata TEXT,
          timestamp TEXT NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      // Tabla de configuración de la aplicación
      await db.execute('''
        CREATE TABLE app_config (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Insertar configuración inicial
      await db.insert('app_config', {
        'key': 'database_version',
        'value': version.toString(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await db.insert('app_config', {
        'key': 'first_run',
        'value': 'true',
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Tabla de productos en cache
      await db.execute('''
      CREATE TABLE cached_products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        default_code TEXT NOT NULL,
        barcode TEXT NOT NULL UNIQUE,
        qty_available REAL NOT NULL,
        location TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        categ_id INTEGER NOT NULL,
        list_price REAL NOT NULL,
        standard_price REAL NOT NULL,
        uom_name TEXT NOT NULL,
        company_id INTEGER NOT NULL,
        last_updated TEXT NOT NULL,
        is_optimistic INTEGER DEFAULT 0,
        operation_id TEXT,
        cached_at TEXT NOT NULL
      )
    ''');

      // Tabla de operaciones
      await db.execute('''
      CREATE TABLE operations (
        operation_id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        product_id INTEGER,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

      await db.execute(
          'CREATE INDEX idx_cached_products_barcode ON cached_products(barcode)');
      await db.execute(
          'CREATE INDEX idx_cached_products_cached_at ON cached_products(cached_at)');
      await db
          .execute('CREATE INDEX idx_operations_status ON operations(status)');
      await db.execute(
          'CREATE INDEX idx_operations_timestamp ON operations(timestamp)');

      _logger.i('Base de datos creada exitosamente');
    } catch (e) {
      _logger.e('Error creando base de datos: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger
        .i('Actualizando base de datos de versión $oldVersion a $newVersion');

    // Aquí agregaremos las migraciones cuando sea necesario
    if (oldVersion < 2) {
      // Ejemplo de migración futura
      // await db.execute('ALTER TABLE users ADD COLUMN new_field TEXT');
    }
  }

  /// Limpiar toda la base de datos
  Future<void> clearDatabase() async {
    try {
      final db = await database;

      await db.delete('audit_logs');
      await db.delete('sessions');
      await db.delete('users');

      _logger.i('Base de datos limpiada');
    } catch (e) {
      _logger.e('Error limpiando base de datos: $e');
      rethrow;
    }
  }

  /// Cerrar base de datos
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.i('Base de datos cerrada');
    }
  }

  /// Obtener configuración
  Future<String?> getConfig(String key) async {
    try {
      final db = await database;
      final result = await db.query(
        'app_config',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (result.isNotEmpty) {
        return result.first['value'] as String;
      }
      return null;
    } catch (e) {
      _logger.e('Error obteniendo configuración $key: $e');
      return null;
    }
  }

  /// Establecer configuración
  Future<void> setConfig(String key, String value) async {
    try {
      final db = await database;
      // CORREGIDO: usar insert con conflictAlgorithm en lugar de insertOrReplace
      await db.insert(
        'app_config',
        {
          'key': key,
          'value': value,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Esto reemplaza si existe
      );
    } catch (e) {
      _logger.e('Error estableciendo configuración $key: $e');
      rethrow;
    }
  }
}
