// lib/features/auth/data/datasources/auth_local_datasource.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/database_helper.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  /// Guardar datos de login
  Future<void> saveLoginData(LoginResponseModel loginResponse);

  /// Obtener usuario desde caché
  Future<UserModel> getCachedUser();

  /// Obtener tokens
  Future<Map<String, String?>> getTokens();

  /// Guardar nuevo access token
  Future<void> saveAccessToken(String accessToken);

  /// Verificar si hay sesión válida
  Future<bool> hasValidSession();

  /// Limpiar todos los datos
  Future<void> clearAllData();

  /// Obtener device ID
  Future<String?> getDeviceId();

  /// Guardar device ID
  Future<void> saveDeviceId(String deviceId);

  /// Obtener última fecha de login
  Future<DateTime?> getLastLogin();

  /// Guardar log de auditoría local
  Future<void> saveAuditLog({
    required String userId,
    required String action,
    String? module,
    required String deviceId,
    Map<String, dynamic>? metadata,
  });

  /// Obtener logs pendientes de sincronización
  Future<List<Map<String, dynamic>>> getPendingAuditLogs();

  /// Marcar logs como sincronizados
  Future<void> markAuditLogsAsSynced(List<String> logIds);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage secureStorage;
  final DatabaseHelper databaseHelper;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.databaseHelper,
  });

  @override
  Future<void> saveLoginData(LoginResponseModel loginResponse) async {
    try {
      // Guardar tokens en secure storage
      await secureStorage.saveAccessToken(loginResponse.accessToken);
      await secureStorage.saveRefreshToken(loginResponse.refreshToken);

      // Guardar datos del usuario en secure storage (para acceso rápido)
      final userJson = json.encode((loginResponse.user as UserModel).toJson());
      await secureStorage.saveUserData(userJson);

      // Guardar fecha de login
      await secureStorage.saveLastLogin(DateTime.now());

      // Guardar usuario en base de datos SQLite
      final db = await databaseHelper.database;
      final userModel = loginResponse.user as UserModel;

      await db.insert(
        'users',
        userModel.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Guardar sesión en base de datos
      await db.insert(
        'sessions',
        {
          'id': _generateSessionId(),
          'user_id': userModel.id,
          'device_identifier': await getDeviceId() ?? 'unknown',
          'access_token': loginResponse.accessToken,
          'refresh_token': loginResponse.refreshToken,
          'expires_at': loginResponse.expiresAt.toIso8601String(),
          'is_active': 1,
          'created_at': DateTime.now().toIso8601String(),
          'last_activity': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Error guardando datos de login: $e');
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      // Intentar obtener desde secure storage primero (más rápido)
      final userDataJson = await secureStorage.getUserData();
      if (userDataJson != null) {
        final userMap = json.decode(userDataJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }

      // Si no está en secure storage, buscar en base de datos
      final db = await databaseHelper.database;
      final result = await db.query(
        'users',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'updated_at DESC',
        limit: 1,
      );

      if (result.isNotEmpty) {
        return UserModel.fromDatabase(result.first);
      }

      throw CacheException('No hay usuario en caché');
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Error obteniendo usuario desde caché: $e');
    }
  }

  @override
  Future<Map<String, String?>> getTokens() async {
    try {
      final accessToken = await secureStorage.getAccessToken();
      final refreshToken = await secureStorage.getRefreshToken();

      return {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
    } catch (e) {
      throw CacheException('Error obteniendo tokens: $e');
    }
  }

  @override
  Future<void> saveAccessToken(String accessToken) async {
    try {
      await secureStorage.saveAccessToken(accessToken);

      // Actualizar también en la base de datos
      final db = await databaseHelper.database;
      await db.update(
        'sessions',
        {
          'access_token': accessToken,
          'last_activity': DateTime.now().toIso8601String(),
        },
        where: 'is_active = ?',
        whereArgs: [1],
      );
    } catch (e) {
      throw CacheException('Error guardando access token: $e');
    }
  }

  @override
  Future<bool> hasValidSession() async {
    try {
      return await secureStorage.hasValidSession();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      // Limpiar secure storage
      await secureStorage.clearAll();

      // Limpiar base de datos
      await databaseHelper.clearDatabase();
    } catch (e) {
      throw CacheException('Error limpiando datos: $e');
    }
  }

  @override
  Future<String?> getDeviceId() async {
    try {
      return await secureStorage.getDeviceId();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveDeviceId(String deviceId) async {
    try {
      await secureStorage.saveDeviceId(deviceId);
    } catch (e) {
      throw CacheException('Error guardando device ID: $e');
    }
  }

  @override
  Future<DateTime?> getLastLogin() async {
    try {
      return await secureStorage.getLastLogin();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAuditLog({
    required String userId,
    required String action,
    String? module,
    required String deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final db = await databaseHelper.database;

      await db.insert('audit_logs', {
        'id': _generateLogId(),
        'user_id': userId,
        'action': action,
        'module': module,
        'device_identifier': deviceId,
        'metadata': metadata != null ? json.encode(metadata) : null,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': 0, // No sincronizado aún
      });
    } catch (e) {
      throw CacheException('Error guardando log de auditoría: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingAuditLogs() async {
    try {
      final db = await databaseHelper.database;

      return await db.query(
        'audit_logs',
        where: 'synced = ?',
        whereArgs: [0],
        orderBy: 'timestamp ASC',
      );
    } catch (e) {
      throw CacheException('Error obteniendo logs pendientes: $e');
    }
  }

  @override
  Future<void> markAuditLogsAsSynced(List<String> logIds) async {
    try {
      final db = await databaseHelper.database;

      for (final logId in logIds) {
        await db.update(
          'audit_logs',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [logId],
        );
      }
    } catch (e) {
      throw CacheException('Error marcando logs como sincronizados: $e');
    }
  }

  // Métodos auxiliares privados
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateLogId() {
    return 'log_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
