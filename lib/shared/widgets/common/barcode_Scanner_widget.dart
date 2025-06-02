import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onDetect;
  final Function() onClose;

  const BarcodeScannerWidget({
    super.key,
    required this.onDetect,
    required this.onClose,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  MobileScannerController controller = MobileScannerController();
  bool _torchEnabled = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código'),
        actions: [
          IconButton(
            icon: Icon(_torchEnabled ? Icons.flash_off : Icons.flash_on),
            onPressed: () async {
              await controller.toggleTorch();
              setState(() {
                _torchEnabled = !_torchEnabled;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              widget.onDetect(barcode.rawValue!);
              return;
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onClose,
        child: const Icon(Icons.close),
      ),
    );
  }
}
