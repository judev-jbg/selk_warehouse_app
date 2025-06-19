import 'package:logger/logger.dart';

class BarcodeProcessor {
  static final Logger _logger = Logger();

  // Sufijos comunes de escáneres PDA (incluyendo más variaciones)
  static const List<String> _commonSuffixes = [
    '\n',
    '\t',
    '\r',
    '\x0D',
    '\x0A',
    '\r\n',
    ' ', // Espacio al final
  ];

  // Prefijos que algunos escáneres pueden agregar
  static const List<String> _commonPrefixes = [''];

  /// Procesar código de barras desde escáner PDA o input manual
  static BarcodeProcessResult processScannedBarcode(String rawInput) {
    _logger.d(
        'Procesando código escaneado: "$rawInput" (length: ${rawInput.length})');

    if (rawInput.isEmpty) {
      return BarcodeProcessResult.error('Código vacío');
    }

    // Limpiar sufijos y prefijos
    String cleanedBarcode = _cleanBarcode(rawInput);

    // Validar longitud después de limpiar
    if (cleanedBarcode.isEmpty) {
      return BarcodeProcessResult.error('Código vacío después de limpiar');
    }

    // Validar que contenga solo números (para EAN13/DUN14)
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedBarcode)) {
      return BarcodeProcessResult.error(
          'Código contiene caracteres inválidos. Solo se permiten números.');
    }

    // Validar longitud esperada
    if (cleanedBarcode.length < 8 || cleanedBarcode.length > 14) {
      return BarcodeProcessResult.error(
          'Longitud inválida: ${cleanedBarcode.length} dígitos (esperado: 8-14)');
    }

    // Detectar tipo de código
    final barcodeType = _detectBarcodeType(cleanedBarcode);

    // Validar checksum si es EAN13 o DUN14
    bool isValidChecksum = true;
    String validationMessage = '';

    if (barcodeType == BarcodeType.ean13) {
      isValidChecksum = validateEAN13Checksum(cleanedBarcode);
      if (!isValidChecksum) {
        validationMessage = 'Checksum EAN13 inválido';
      }
    } else if (barcodeType == BarcodeType.dun14) {
      isValidChecksum = validateDUN14Checksum(cleanedBarcode);
      if (!isValidChecksum) {
        validationMessage = 'Checksum DUN14 inválido';
      }
    }

    _logger.i(
        'Código procesado: "$cleanedBarcode" (tipo: ${barcodeType.displayName}, '
        'válido: $isValidChecksum)');

    return BarcodeProcessResult.success(
      cleanedBarcode: cleanedBarcode,
      originalInput: rawInput,
      barcodeType: barcodeType,
      hadSuffixes: rawInput != cleanedBarcode,
      isValidChecksum: isValidChecksum,
      validationMessage: validationMessage,
    );
  }

  /// Limpiar código de barras de manera más robusta
  static String _cleanBarcode(String input) {
    String cleaned = input;

    // Remover sufijos comunes en orden específico
    for (final suffix in _commonSuffixes) {
      while (cleaned.endsWith(suffix)) {
        cleaned = cleaned.substring(0, cleaned.length - suffix.length);
      }
    }

    // Remover prefijos comunes
    for (final prefix in _commonPrefixes) {
      if (prefix.isNotEmpty && cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length);
      }
    }

    // Trim espacios en blanco y caracteres de control
    cleaned = cleaned.trim();

    // Remover caracteres de control Unicode
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');

    return cleaned;
  }

  /// Detectar si el input viene de un escáner (tiene sufijos)
  static bool isFromScanner(String input) {
    return _commonSuffixes.any((suffix) => input.contains(suffix));
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

  /// Generar código de ejemplo para testing
  static String generateSampleEAN13() {
    final code = List.generate(12,
            (_) => (0 + (9 * (DateTime.now().microsecond % 10) / 10).floor()))
        .join();
    final checkDigit = _calculateEAN13CheckDigit(code);
    return code + checkDigit.toString();
  }

  static int _calculateEAN13CheckDigit(String code) {
    final digits = code.split('').map(int.parse).toList();
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += digits[i] * (i % 2 == 0 ? 1 : 3);
    }
    final remainder = sum % 10;
    return remainder == 0 ? 0 : 10 - remainder;
  }
}

/// Resultado del procesamiento de código de barras (actualizado)
class BarcodeProcessResult {
  final bool isSuccess;
  final String? cleanedBarcode;
  final String? originalInput;
  final BarcodeType? barcodeType;
  final bool hadSuffixes;
  final bool isValidChecksum;
  final String? validationMessage;
  final String? error;

  const BarcodeProcessResult._({
    required this.isSuccess,
    this.cleanedBarcode,
    this.originalInput,
    this.barcodeType,
    this.hadSuffixes = false,
    this.isValidChecksum = true,
    this.validationMessage,
    this.error,
  });

  factory BarcodeProcessResult.success({
    required String cleanedBarcode,
    required String originalInput,
    required BarcodeType barcodeType,
    required bool hadSuffixes,
    bool isValidChecksum = true,
    String? validationMessage,
  }) {
    return BarcodeProcessResult._(
      isSuccess: true,
      cleanedBarcode: cleanedBarcode,
      originalInput: originalInput,
      barcodeType: barcodeType,
      hadSuffixes: hadSuffixes,
      isValidChecksum: isValidChecksum,
      validationMessage: validationMessage,
    );
  }

  factory BarcodeProcessResult.error(String error) {
    return BarcodeProcessResult._(
      isSuccess: false,
      error: error,
    );
  }

  /// Información para debugging
  Map<String, dynamic> toDebugMap() {
    return {
      'isSuccess': isSuccess,
      'cleanedBarcode': cleanedBarcode,
      'originalInput': originalInput,
      'barcodeType': barcodeType?.displayName,
      'hadSuffixes': hadSuffixes,
      'isValidChecksum': isValidChecksum,
      'validationMessage': validationMessage,
      'error': error,
    };
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

  String get description {
    switch (this) {
      case BarcodeType.ean13:
        return 'Código de barras estándar de 13 dígitos';
      case BarcodeType.dun14:
        return 'Código de barras de distribución de 14 dígitos';
      case BarcodeType.ean8:
        return 'Código de barras corto de 8 dígitos';
      case BarcodeType.upc:
        return 'Código UPC de 12 dígitos';
      case BarcodeType.unknown:
        return 'Tipo de código desconocido';
    }
  }
}
