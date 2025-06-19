import 'package:logger/logger.dart';

class BarcodeProcessor {
  static final Logger _logger = Logger();

  // Sufijos comunes de escáneres PDA
  static const List<String> _commonSuffixes = [
    '\n',
    '\t',
    '\r',
    '\x0D',
    '\x0A'
  ];

  // Prefijos que algunos escáneres pueden agregar
  static const List<String> _commonPrefixes = [''];

  /// Procesar código de barras desde escáner PDA
  static BarcodeProcessResult processScannedBarcode(String rawInput) {
    _logger.d('Procesando código escaneado: "$rawInput"');

    if (rawInput.isEmpty) {
      return BarcodeProcessResult.error('Código vacío');
    }

    // Limpiar sufijos y prefijos
    String cleanedBarcode = _cleanBarcode(rawInput);

    // Validar longitud
    if (cleanedBarcode.isEmpty) {
      return BarcodeProcessResult.error('Código vacío después de limpiar');
    }

    // Validar formato (solo números para EAN13/DUN14)
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedBarcode)) {
      return BarcodeProcessResult.error('Código contiene caracteres inválidos');
    }

    // Validar longitud esperada
    if (cleanedBarcode.length < 8 || cleanedBarcode.length > 14) {
      return BarcodeProcessResult.error(
          'Longitud inválida: ${cleanedBarcode.length} (esperado: 8-14 dígitos)');
    }

    // Detectar tipo de código
    final barcodeType = _detectBarcodeType(cleanedBarcode);

    _logger.i('Código procesado: "$cleanedBarcode" (tipo: $barcodeType)');

    return BarcodeProcessResult.success(
      cleanedBarcode: cleanedBarcode,
      originalInput: rawInput,
      barcodeType: barcodeType,
      hadSuffixes: rawInput != cleanedBarcode,
    );
  }

  /// Limpiar código de barras
  static String _cleanBarcode(String input) {
    String cleaned = input;

    // Remover sufijos comunes
    for (final suffix in _commonSuffixes) {
      cleaned = cleaned.replaceAll(suffix, '');
    }

    // Remover prefijos comunes (si los hubiera)
    for (final prefix in _commonPrefixes) {
      if (prefix.isNotEmpty && cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length);
      }
    }

    // Trim espacios en blanco
    cleaned = cleaned.trim();

    return cleaned;
  }

  /// Detectar tipo de código de barras
  static BarcodeType _detectBarcodeType(String barcode) {
    switch (barcode.length) {
      case 8:
        return BarcodeType.ean8;
      case 12:
        return BarcodeType.upc;
      case 13:
        return BarcodeType.ean13;
      case 14:
        return BarcodeType.dun14;
      default:
        return BarcodeType.unknown;
    }
  }

  /// Validar checksum de EAN13
  static bool validateEAN13Checksum(String barcode) {
    if (barcode.length != 13) return false;

    try {
      final digits = barcode.split('').map(int.parse).toList();
      int sum = 0;

      for (int i = 0; i < 12; i++) {
        sum += digits[i] * (i % 2 == 0 ? 1 : 3);
      }

      final checkDigit = (10 - (sum % 10)) % 10;
      return checkDigit == digits[12];
    } catch (e) {
      return false;
    }
  }

  /// Validar checksum de DUN14
  static bool validateDUN14Checksum(String barcode) {
    if (barcode.length != 14) return false;

    try {
      final digits = barcode.split('').map(int.parse).toList();
      int sum = 0;

      for (int i = 0; i < 13; i++) {
        sum += digits[i] * (i % 2 == 0 ? 3 : 1);
      }

      final checkDigit = (10 - (sum % 10)) % 10;
      return checkDigit == digits[13];
    } catch (e) {
      return false;
    }
  }
}

/// Resultado del procesamiento de código de barras
class BarcodeProcessResult {
  final bool isSuccess;
  final String? cleanedBarcode;
  final String? originalInput;
  final BarcodeType? barcodeType;
  final bool hadSuffixes;
  final String? error;

  const BarcodeProcessResult._({
    required this.isSuccess,
    this.cleanedBarcode,
    this.originalInput,
    this.barcodeType,
    this.hadSuffixes = false,
    this.error,
  });

  factory BarcodeProcessResult.success({
    required String cleanedBarcode,
    required String originalInput,
    required BarcodeType barcodeType,
    required bool hadSuffixes,
  }) {
    return BarcodeProcessResult._(
      isSuccess: true,
      cleanedBarcode: cleanedBarcode,
      originalInput: originalInput,
      barcodeType: barcodeType,
      hadSuffixes: hadSuffixes,
    );
  }

  factory BarcodeProcessResult.error(String error) {
    return BarcodeProcessResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Tipos de códigos de barras soportados
enum BarcodeType {
  ean8,
  ean13,
  upc,
  dun14,
  unknown,
}

extension BarcodeTypeExtension on BarcodeType {
  String get displayName {
    switch (this) {
      case BarcodeType.ean8:
        return 'EAN-8';
      case BarcodeType.ean13:
        return 'EAN-13';
      case BarcodeType.upc:
        return 'UPC';
      case BarcodeType.dun14:
        return 'DUN-14';
      case BarcodeType.unknown:
        return 'Desconocido';
    }
  }

  bool get isSupported {
    return this == BarcodeType.ean13 || this == BarcodeType.dun14;
  }
}
