import 'dart:async';
import 'package:flutter/services.dart';

/// Servicio para interactuar con el escáner de código de barras de la PDA Sunmi L2H
class SunmiScannerService {
  static const MethodChannel _channel = MethodChannel(
    'com.selk.warehouse/sunmi_scanner',
  );
  static const EventChannel _scanChannel = EventChannel(
    'com.selk.warehouse/sunmi_scanner_events',
  );

  Stream<String>? _scanStream;

  /// Inicializa el escáner
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error al inicializar el escáner: ${e.message}');
      return false;
    }
  }

  /// Comienza a escuchar eventos del escáner
  Stream<String> get scanStream {
    _scanStream ??= _scanChannel.receiveBroadcastStream().map<String>(
      (dynamic event) => event.toString(),
    );
    return _scanStream!;
  }

  /// Activa manualmente el escáner
  Future<bool> startScan() async {
    try {
      final result = await _channel.invokeMethod<bool>('startScan');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error al iniciar el escaneo: ${e.message}');
      return false;
    }
  }

  /// Detiene manualmente el escáner
  Future<bool> stopScan() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopScan');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error al detener el escaneo: ${e.message}');
      return false;
    }
  }

  /// Configura el comportamiento del escáner
  Future<bool> configure({
    bool? enableContinuousScan,
    String? scanResultSuffix,
    int? scanTimeout,
  }) async {
    try {
      final Map<String, dynamic> arguments = {};

      if (enableContinuousScan != null) {
        arguments['enableContinuousScan'] = enableContinuousScan;
      }

      if (scanResultSuffix != null) {
        arguments['scanResultSuffix'] = scanResultSuffix;
      }

      if (scanTimeout != null) {
        arguments['scanTimeout'] = scanTimeout;
      }

      final result = await _channel.invokeMethod<bool>('configure', arguments);
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error al configurar el escáner: ${e.message}');
      return false;
    }
  }
}
