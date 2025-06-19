// lib/features/colocacion/presentation/widgets/barcode_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../data/services/barcode_processor.dart';

class BarcodeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final bool enabled;

  const BarcodeSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    this.onClear,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<BarcodeSearchBar> createState() => _BarcodeSearchBarState();
}

class _BarcodeSearchBarState extends State<BarcodeSearchBar> {
  String _lastProcessedValue = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  /// Detectar cambios en el texto y procesar códigos de barras
  void _onTextChanged() {
    if (_isProcessing) return;

    final currentText = widget.controller.text;

    // Evitar procesar el mismo valor múltiples veces
    if (currentText == _lastProcessedValue) return;

    // Detectar si viene de escáner (contiene sufijos)
    final isFromScanner = BarcodeProcessor.isFromScanner(currentText);

    if (isFromScanner && currentText.isNotEmpty) {
      _processScannedCode(currentText);
    }
  }

  /// Procesar código escaneado
  void _processScannedCode(String scannedCode) async {
    setState(() => _isProcessing = true);

    try {
      // Procesar con BarcodeProcessor
      final processResult = BarcodeProcessor.processScannedBarcode(scannedCode);

      if (processResult.isSuccess) {
        final cleanedCode = processResult.cleanedBarcode!;
        _lastProcessedValue = cleanedCode;

        // Limpiar el campo y ejecutar búsqueda
        widget.controller.clear();

        // Pequeño delay para mejorar UX
        await Future.delayed(const Duration(milliseconds: 50));

        // Ejecutar búsqueda
        widget.onSearch(cleanedCode);

        // Mostrar información de debug en desarrollo
        debugPrint('🔍 Código procesado: ${processResult.toDebugMap()}');
      } else {
        // Mostrar error de procesamiento
        _showBarcodeError(processResult.error!);
        widget.controller.clear();
      }
    } catch (e) {
      _showBarcodeError('Error procesando código: $e');
      widget.controller.clear();
    } finally {
      setState(() => _isProcessing = false);

      // Restaurar foco después de un pequeño delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && widget.focusNode.canRequestFocus) {
          widget.focusNode.requestFocus();
        }
      });
    }
  }

  /// Mostrar error de código de barras
  void _showBarcodeError(String error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Código inválido: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.focusNode.hasFocus
              ? AppColors.primary
              : _isProcessing
                  ? AppColors.warning
                  : AppColors.divider,
          width: widget.focusNode.hasFocus || _isProcessing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled && !_isProcessing,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        inputFormatters: [
          // Permitir números y caracteres de control del escáner
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\n\t\r\x0D\x0A ]')),
        ],
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: _isProcessing
              ? 'Procesando código...'
              : 'Escanear o ingresar código de barras...',
          hintStyle: TextStyle(
            color: _isProcessing ? AppColors.warning : AppColors.textHint,
            fontSize: 16,
          ),
          prefixIcon: _isProcessing
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.warning),
                    ),
                  ),
                )
              : Icon(
                  Icons.qr_code_scanner,
                  color: widget.focusNode.hasFocus
                      ? AppColors.primary
                      : AppColors.textHint,
                  size: 24,
                ),
          suffixIcon: widget.controller.text.isNotEmpty && !_isProcessing
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textHint),
                  onPressed: () {
                    widget.controller.clear();
                    _lastProcessedValue = '';
                    widget.onClear?.call();
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textHint),
                  onPressed: _isProcessing
                      ? null
                      : () {
                          final text = widget.controller.text.trim();
                          if (text.isNotEmpty) {
                            widget.onSearch(text);
                          }
                        },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onSubmitted: _isProcessing
            ? null
            : (value) {
                if (value.trim().isNotEmpty) {
                  widget.onSearch(value.trim());
                }
              },
        onTap: () {
          // Asegurar que el foco esté en el campo
          if (!widget.focusNode.hasFocus) {
            widget.focusNode.requestFocus();
          }
        },
      ),
    );
  }
}
