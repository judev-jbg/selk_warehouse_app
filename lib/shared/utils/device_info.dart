// lib/shared/utils/device_info.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeviceInfoUtil {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Generar identificador único del dispositivo
  static Future<String> generateDeviceId() async {
    try {
      String identifier = '';

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        identifier =
            '${androidInfo.brand}-${androidInfo.model}-${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        identifier = '${iosInfo.name}-${iosInfo.identifierForVendor}';
      }

      // Crear hash del identificador para mayor seguridad
      final bytes = utf8.encode('${identifier}SELK');
      final digest = sha256.convert(bytes);

      return 'PDA-SELK-${digest.toString().substring(0, 16).toUpperCase()}';
    } catch (e) {
      // Fallback si no se puede obtener info del dispositivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'PDA-SELK-FALLBACK-$timestamp';
    }
  }

  /// Obtener información completa del dispositivo
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return {
          'platform': 'Android',
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
          'manufacturer': androidInfo.manufacturer,
          'hardware': androidInfo.hardware,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return {
          'platform': 'iOS',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
          'identifier': iosInfo.identifierForVendor,
        };
      }

      return {'platform': 'Unknown'};
    } catch (e) {
      return {'platform': 'Error', 'error': e.toString()};
    }
  }
}
