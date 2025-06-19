import '../../domain/entities/operation_result.dart';
import '../../domain/entities/product.dart';
import 'product_model.dart';

class OperationResultModel extends OperationResult {
  const OperationResultModel({
    required super.operationId,
    required super.type,
    required super.status,
    super.product,
    required super.message,
    required super.timestamp,
    super.error,
  });

  /// Crear desde respuesta del backend para actualización
  factory OperationResultModel.fromUpdateResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final operation = data?['operation'] as Map<String, dynamic>?;

    return OperationResultModel(
      operationId: operation?['id'] as String? ?? '',
      type: _parseOperationType(operation?['type'] as String?),
      status: _parseOperationStatus(operation?['status'] as String?),
      product: data?['product'] != null
          ? ProductModel.fromJson(data!['product'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String? ?? '',
      timestamp: DateTime.now(),
      error: json['error'] as String?,
    );
  }

  /// Crear desde WebSocket notification
  factory OperationResultModel.fromWebSocket(Map<String, dynamic> json) {
    return OperationResultModel(
      operationId: json['operationId'] as String? ?? '',
      type: _parseOperationType(json['type'] as String?),
      status: _parseOperationStatus(json['status'] as String?),
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      error: json['error'] as String?,
    );
  }

  /// Crear resultado optimista
  factory OperationResultModel.optimistic({
    required String operationId,
    required OperationType type,
    required Product product,
    required String message,
  }) {
    return OperationResultModel(
      operationId: operationId,
      type: type,
      status: OperationStatus.pending,
      product: product,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  /// Parsear tipo de operación desde string
  static OperationType _parseOperationType(String? type) {
    switch (type) {
      case 'location_update':
        return OperationType.locationUpdate;
      case 'stock_update':
        return OperationType.stockUpdate;
      default:
        return OperationType.stockUpdate;
    }
  }

  /// Parsear estado de operación desde string
  static OperationStatus _parseOperationStatus(String? status) {
    switch (status) {
      case 'pending':
      case 'optimistic':
        return OperationStatus.pending;
      case 'success':
      case 'confirmed':
        return OperationStatus.success;
      case 'failed':
        return OperationStatus.failed;
      case 'rolled_back':
        return OperationStatus.rolledBack;
      default:
        return OperationStatus.pending;
    }
  }

  /// Convertir a JSON para cache
  Map<String, dynamic> toJson() {
    return {
      'operationId': operationId,
      'type': type.name,
      'status': status.name,
      'product': product != null ? (product! as ProductModel).toJson() : null,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
    };
  }
}
