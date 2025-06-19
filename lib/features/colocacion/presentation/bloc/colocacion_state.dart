import 'package:equatable/equatable.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/entities/label.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_search_result.dart';
import '../../domain/entities/operation_result.dart';

abstract class ColocacionState extends Equatable {
  const ColocacionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ColocacionInitial extends ColocacionState {}

/// Estado de carga
class ColocacionLoading extends ColocacionState {
  final String? message;

  const ColocacionLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado con producto encontrado
class ColocacionProductFound extends ColocacionState {
  final ProductSearchResult searchResult;
  final List<OperationResult> pendingOperations;

  const ColocacionProductFound({
    required this.searchResult,
    this.pendingOperations = const [],
  });

  @override
  List<Object?> get props => [searchResult, pendingOperations];

  Product get product => searchResult.product!;
  bool get isCached => searchResult.cached;
  int get searchTime => searchResult.searchTime;
}

/// Estado cuando no se encuentra producto
class ColocacionProductNotFound extends ColocacionState {
  final String error;
  final String? barcode;

  const ColocacionProductNotFound({
    required this.error,
    this.barcode,
  });

  @override
  List<Object?> get props => [error, barcode];
}

/// Estado después de actualización exitosa
class ColocacionUpdateSuccess extends ColocacionState {
  final OperationResult operationResult;
  final String fieldUpdated;

  const ColocacionUpdateSuccess({
    required this.operationResult,
    required this.fieldUpdated,
  });

  @override
  List<Object?> get props => [operationResult, fieldUpdated];

  Product get updatedProduct => operationResult.product!;
  bool get isOptimistic => operationResult.isOptimistic;
  String get message => operationResult.message;
}

/// Estado de error
class ColocacionError extends ColocacionState {
  final String message;
  final String? code;

  const ColocacionError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Estado con operaciones pendientes
class ColocacionPendingOperations extends ColocacionState {
  final List<OperationResult> operations;

  const ColocacionPendingOperations({required this.operations});

  @override
  List<Object?> get props => [operations];

  int get pendingCount => operations.where((op) => op.isOptimistic).length;
  bool get hasPendingOperations => pendingCount > 0;
}

/// Estado después de limpiar cache
class ColocacionCacheCleared extends ColocacionState {
  final DateTime timestamp;

  const ColocacionCacheCleared({required this.timestamp});

  @override
  List<Object?> get props => [timestamp];
}

/// Estado de conexión perdida
class ColocacionOffline extends ColocacionState {
  final String message;

  const ColocacionOffline({
    this.message = 'Sin conexión a internet',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado de notificación en tiempo real
class ColocacionRealtimeUpdate extends ColocacionState {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const ColocacionRealtimeUpdate({
    required this.type,
    required this.data,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [type, data, timestamp];
}

/// Estado con etiqueta creada exitosamente
class ColocacionLabelCreated extends ColocacionState {
  final Label label;
  final String message;

  const ColocacionLabelCreated({
    required this.label,
    this.message = 'Etiqueta creada exitosamente',
  });

  @override
  List<Object?> get props => [label, message];
}

/// Estado con etiquetas pendientes cargadas
class ColocacionLabelsLoaded extends ColocacionState {
  final List<Label> labels;
  final String type; // 'pending', 'history'

  const ColocacionLabelsLoaded({
    required this.labels,
    required this.type,
  });

  @override
  List<Object?> get props => [labels, type];

  int get pendingCount => labels.where((label) => label.canBePrinted).length;
  bool get hasLabels => labels.isNotEmpty;
}

/// Estado después de marcar etiquetas como impresas
class ColocacionLabelsMarkedAsPrinted extends ColocacionState {
  final List<String> labelIds;
  final int count;

  const ColocacionLabelsMarkedAsPrinted({
    required this.labelIds,
    required this.count,
  });

  @override
  List<Object?> get props => [labelIds, count];
}

/// Estado después de eliminar etiquetas
class ColocacionLabelsDeleted extends ColocacionState {
  final List<String> labelIds;
  final int count;

  const ColocacionLabelsDeleted({
    required this.labelIds,
    required this.count,
  });

  @override
  List<Object?> get props => [labelIds, count];
}
