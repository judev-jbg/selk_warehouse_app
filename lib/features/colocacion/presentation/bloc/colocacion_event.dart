import 'package:equatable/equatable.dart';

abstract class ColocacionEvent extends Equatable {
  const ColocacionEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: buscar producto por código de barras
class ColocacionSearchProduct extends ColocacionEvent {
  final String barcode;
  final bool useCache;

  const ColocacionSearchProduct({
    required this.barcode,
    this.useCache = true,
  });

  @override
  List<Object?> get props => [barcode, useCache];
}

/// Evento: actualizar localización de producto
class ColocacionUpdateLocation extends ColocacionEvent {
  final int productId;
  final String newLocation;

  const ColocacionUpdateLocation({
    required this.productId,
    required this.newLocation,
  });

  @override
  List<Object?> get props => [productId, newLocation];
}

/// Evento: actualizar stock de producto
class ColocacionUpdateStock extends ColocacionEvent {
  final int productId;
  final double newStock;

  const ColocacionUpdateStock({
    required this.productId,
    required this.newStock,
  });

  @override
  List<Object?> get props => [productId, newStock];
}

/// Evento: limpiar resultados de búsqueda
class ColocacionClearSearch extends ColocacionEvent {}

/// Evento: limpiar error
class ColocacionClearError extends ColocacionEvent {}

/// Evento: confirmar operación pendiente
class ColocacionConfirmOperation extends ColocacionEvent {
  final String operationId;

  const ColocacionConfirmOperation({required this.operationId});

  @override
  List<Object?> get props => [operationId];
}

/// Evento: cancelar operación pendiente
class ColocacionCancelOperation extends ColocacionEvent {
  final String operationId;

  const ColocacionCancelOperation({required this.operationId});

  @override
  List<Object?> get props => [operationId];
}

/// Evento: obtener operaciones pendientes
class ColocacionGetPendingOperations extends ColocacionEvent {}

/// Evento: limpiar cache
class ColocacionClearCache extends ColocacionEvent {}

/// Evento: notificación de WebSocket recibida
class ColocacionWebSocketNotification extends ColocacionEvent {
  final Map<String, dynamic> data;

  const ColocacionWebSocketNotification({required this.data});

  @override
  List<Object?> get props => [data];
}

/// Evento: reinicializar estado
class ColocacionReset extends ColocacionEvent {}
