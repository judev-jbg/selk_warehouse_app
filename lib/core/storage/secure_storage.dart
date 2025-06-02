// lib/core/storage/secure_storage.dart (corregir imports y constructor)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  static SecureStorage? _instance;
  final FlutterSecureStorage _storage;
  final Logger _logger = Logger();

  // CORREGIDO: usar KeychainAccessibility en lugar de IOSAccessibility
  SecureStorage._internal()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
            keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
            storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
          ),
          iOptions: IOSOptions(
            accessibility:
                KeychainAccessibility.first_unlock_this_device, // CORREGIDO
          ),
        );

  factory SecureStorage() {
    _instance ??= SecureStorage._internal();
    return _instance!;
  }

  /// Guardar token de acceso
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: AppConstants.keyAccessToken, value: token);
      _logger.d('Token de acceso guardado');
    } catch (e) {
      _logger.e('Error guardando token de acceso: $e');
      rethrow;
    }
  }

  /// Obtener token de acceso
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.keyAccessToken);
    } catch (e) {
      _logger.e('Error obteniendo token de acceso: $e');
      return null;
    }
  }

  /// Guardar refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: AppConstants.keyRefreshToken, value: token);
      _logger.d('Refresh token guardado');
    } catch (e) {
      _logger.e('Error guardando refresh token: $e');
      rethrow;
    }
  }

  /// Obtener refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.keyRefreshToken);
    } catch (e) {
      _logger.e('Error obteniendo refresh token: $e');
      return null;
    }
  }

  /// Guardar device ID
  Future<void> saveDeviceId(String deviceId) async {
    try {
      await _storage.write(key: AppConstants.keyDeviceId, value: deviceId);
      _logger.d('Device ID guardado');
    } catch (e) {
      _logger.e('Error guardando device ID: $e');
      rethrow;
    }
  }

  /// Obtener device ID
  Future<String?> getDeviceId() async {
    try {
      return await _storage.read(key: AppConstants.keyDeviceId);
    } catch (e) {
      _logger.e('Error obteniendo device ID: $e');
      return null;
    }
  }

  /// Guardar datos de usuario
  Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: AppConstants.keyUserData, value: userData);
      _logger.d('Datos de usuario guardados');
    } catch (e) {
      _logger.e('Error guardando datos de usuario: $e');
      rethrow;
    }
  }

  /// Obtener datos de usuario
  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: AppConstants.keyUserData);
    } catch (e) {
      _logger.e('Error obteniendo datos de usuario: $e');
      return null;
    }
  }

  /// Guardar fecha de último login
  Future<void> saveLastLogin(DateTime lastLogin) async {
    try {
      await _storage.write(
        key: AppConstants.keyLastLogin,
        value: lastLogin.toIso8601String(),
      );
      _logger.d('Fecha de último login guardada');
    } catch (e) {
      _logger.e('Error guardando fecha de último login: $e');
      rethrow;
    }
  }

  /// Obtener fecha de último login
  Future<DateTime?> getLastLogin() async {
    try {
      final lastLoginStr = await _storage.read(key: AppConstants.keyLastLogin);
      if (lastLoginStr != null) {
        return DateTime.parse(lastLoginStr);
      }
      return null;
    } catch (e) {
      _logger.e('Error obteniendo fecha de último login: $e');
      return null;
    }
  }

  /// Limpiar todos los datos
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _logger.i('Almacenamiento seguro limpiado');
    } catch (e) {
      _logger.e('Error limpiando almacenamiento seguro: $e');
      rethrow;
    }
  }

  /// Verificar si hay datos de sesión
  Future<bool> hasValidSession() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      final deviceId = await getDeviceId();

      return accessToken != null && refreshToken != null && deviceId != null;
    } catch (e) {
      _logger.e('Error verificando sesión válida: $e');
      return false;
    }
  }
}
