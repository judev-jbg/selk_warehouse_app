import 'package:equatable/equatable.dart';
import 'product.dart';

enum OperationStatus { pending, success, failed, rolledBack }

enum OperationType { locationUpdate, stockUpdate }

class OperationResult extends Equatable {
  final String operationId;
  final OperationType type;
  final OperationStatus status;
  final Product? product;
  final String message;
  final DateTime timestamp;
  final String? error;

  const OperationResult({
    required this.operationId,
    required this.type,
    required this.status,
    this.product,
    required this.message,
    required this.timestamp,
    this.error,
  });

  @override
  List<Object?> get props => [
        operationId,
        type,
        status,
        product,
        message,
        timestamp,
        error,
      ];

  OperationResult copyWith({
    String? operationId,
    OperationType? type,
    OperationStatus? status,
    Product? product,
    String? message,
    DateTime? timestamp,
    String? error,
  }) {
    return OperationResult(
      operationId: operationId ?? this.operationId,
      type: type ?? this.type,
      status: status ?? this.status,
      product: product ?? this.product,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      error: error ?? this.error,
    );
  }

  bool get isOptimistic => status == OperationStatus.pending;
  bool get isSuccess => status == OperationStatus.success;
  bool get isFailed => status == OperationStatus.failed;
  bool get isRolledBack => status == OperationStatus.rolledBack;
}
