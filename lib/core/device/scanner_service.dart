import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerService {
  MobileScannerController? _controller;

  // Inicializa el controlador del escáner
  MobileScannerController initializeScanner() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    return _controller!;
  }

  // Libera recursos
  void dispose() {
    _controller?.dispose();
  }

  // Activa/desactiva la linterna
  Future<void> toggleTorch() async {
    await _controller?.toggleTorch();
  }

  // Cambia entre cámaras frontal y trasera
  Future<void> switchCamera() async {
    await _controller?.switchCamera();
  }
}
