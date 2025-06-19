import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/search_product_by_barcode.dart';
import '../../domain/usecases/update_product_location.dart';
import '../../domain/usecases/update_product_stock.dart';
import '../../domain/repositories/colocacion_repository.dart';
import 'colocacion_event.dart';
import 'colocacion_state.dart';

class ColocacionBloc extends Bloc<ColocacionEvent, ColocacionState> {
  final SearchProductByBarcode searchProductByBarcode;
  final UpdateProductLocation updateProductLocation;
  final UpdateProductStock updateProductStock;
  final ColocacionRepository repository;
  final Logger logger;

  ColocacionBloc({
    required this.searchProductByBarcode,
    required this.updateProductLocation,
    required this.updateProductStock,
    required this.repository,
    required this.logger,
  }) : super(ColocacionInitial()) {
    on<ColocacionSearchProduct>(_onSearchProduct);
    on<ColocacionUpdateLocation>(_onUpdateLocation);
    on<ColocacionUpdateStock>(_onUpdateStock);
    on<ColocacionClearSearch>(_onClearSearch);
    on<ColocacionClearError>(_onClearError);
    on<ColocacionConfirmOperation>(_onConfirmOperation);
    on<ColocacionCancelOperation>(_onCancelOperation);
    on<ColocacionGetPendingOperations>(_onGetPendingOperations);
    on<ColocacionClearCache>(_onClearCache);
    on<ColocacionWebSocketNotification>(_onWebSocketNotification);
    on<ColocacionReset>(_onReset);
  }

  /// Buscar producto por código de barras
  Future<void> _onSearchProduct(
    ColocacionSearchProduct event,
    Emitter<ColocacionState> emit,
  ) async {
    try {
      emit(const ColocacionLoading(message: 'Buscando producto...'));

      logger.i('Buscando producto: ${event.barcode}');

      final result = await searchProductByBarcode(
        SearchProductParams(
          barcode: event.barcode,
          useCache: event.useCache,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Error buscando producto: ${failure.message}');
          emit(ColocacionProductNotFound(
            error: failure.message,
            barcode: event.barcode,
          ));
        },
        (searchResult) {
          if (searchResult.found) {
            logger.i('Producto encontrado: ${searchResult.product!.name}');
            emit(ColocacionProductFound(searchResult: searchResult));
          } else {
            logger.w('Producto no encontrado: ${event.barcode}');
            emit(ColocacionProductNotFound(
              error: searchResult.error ?? 'Producto no encontrado',
              barcode: event.barcode,
            ));
          }
        },
      );
    } catch (e) {
      logger.e('Error inesperado buscando producto: $e');
      emit(ColocacionError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  /// Actualizar localización del producto
  Future<void> _onUpdateLocation(
    ColocacionUpdateLocation event,
    Emitter<ColocacionState> emit,
  ) async {
    try {
      emit(const ColocacionLoading(message: 'Actualizando localización...'));

      logger.i(
          'Actualizando localización: ${event.productId} -> ${event.newLocation}');

      final result = await updateProductLocation(
        UpdateLocationParams(
          productId: event.productId,
          newLocation: event.newLocation,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Error actualizando localización: ${failure.message}');
          emit(ColocacionError(message: failure.message));
        },
        (operationResult) {
          logger.i('Localización actualizada: ${operationResult.message}');
          emit(ColocacionUpdateSuccess(
            operationResult: operationResult,
            fieldUpdated: 'location',
          ));
        },
      );
    } catch (e) {
      logger.e('Error inesperado actualizando localización: $e');
      emit(ColocacionError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  /// Actualizar stock del producto
  Future<void> _onUpdateStock(
    ColocacionUpdateStock event,
    Emitter<ColocacionState> emit,
  ) async {
    try {
      emit(const ColocacionLoading(message: 'Actualizando stock...'));

      logger.i('Actualizando stock: ${event.productId} -> ${event.newStock}');

      final result = await updateProductStock(
        UpdateStockParams(
          productId: event.productId,
          newStock: event.newStock,
        ),
      );

      result.fold(
        (failure) {
          logger.e('Error actualizando stock: ${failure.message}');
          emit(ColocacionError(message: failure.message));
        },
        (operationResult) {
          logger.i('Stock actualizado: ${operationResult.message}');
          emit(ColocacionUpdateSuccess(
            operationResult: operationResult,
            fieldUpdated: 'stock',
          ));
        },
      );
    } catch (e) {
      logger.e('Error inesperado actualizando stock: $e');
      emit(ColocacionError(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  /// Limpiar búsqueda
  void _onClearSearch(
    ColocacionClearSearch event,
    Emitter<ColocacionState> emit,
  ) {
    emit(ColocacionInitial());
  }

  /// Limpiar error
  void _onClearError(
    ColocacionClearError event,
    Emitter<ColocacionState> emit,
  ) {
    emit(ColocacionInitial());
  }

  /// Confirmar operación pendiente
  Future<void> _onConfirmOperation(
    ColocacionConfirmOperation event,
    Emitter<ColocacionState> emit,
  ) async {
    try {
      logger.i('Confirmando operación: ${event.operationId}');

      final result = await repository.getOperationStatus(event.operationId);

      result.fold(
        (failure) => emit(ColocacionError(message: failure.message)),
        (operationResult) {
          // Notificar resultado de la confirmación
          add(ColocacionWebSocketNotification(data: {
            'type': 'operation_confirmed',
            'operationId': event.operationId,
            'status': operationResult.status.name,
          }));
        },
      );
    } catch (e) {
      logger.e('Error confirmando operación: $e');
      emit(ColocacionError(message: 'Error confirmando operación'));
    }
  }

  /// Cancelar operación pendiente
  void _onCancelOperation(
    ColocacionCancelOperation event,
    Emitter<ColocacionState> emit,
  ) {
    logger.i('Cancelando operación: ${event.operationId}');
    // TODO: Implementar cancelación en backend si es necesario
    emit(const ColocacionError(
        message: 'Cancelación de operaciones no implementada'));
  }

  /// Obtener operaciones pendientes
  Future<void> _onGetPendingOperations(
    ColocacionGetPendingOperations event,
    Emitter<ColocacionState> emit,
  ) async {
    try {
      final result = await repository.getPendingOperations();

      result.fold(
        (failure) => emit(ColocacionError(message: failure.message)),
        (operations) =>
            emit(ColocacionPendingOperations(operations: operations)),
      );
    } catch (e) {
      logger.e('Error obteniendo operaciones pendientes: $e');
      emit(ColocacionError(message: 'Error obteniendo operaciones pendientes'));
    }
  }

  /// Limpiar cache
  Future<void> _onClearCache(
    ColocacionClearCache event,
    Emitter<ColocacionState> emit,
  ) async {
    try {
      emit(const ColocacionLoading(message: 'Limpiando cache...'));

      final result = await repository.clearProductCache();

      result.fold(
        (failure) => emit(ColocacionError(message: failure.message)),
        (_) => emit(ColocacionCacheCleared(timestamp: DateTime.now())),
      );
    } catch (e) {
      logger.e('Error limpiando cache: $e');
      emit(ColocacionError(message: 'Error limpiando cache'));
    }
  }

  /// Manejar notificación de WebSocket
  void _onWebSocketNotification(
    ColocacionWebSocketNotification event,
    Emitter<ColocacionState> emit,
  ) {
    final type = event.data['type'] as String?;

    logger.i('Notificación WebSocket recibida: $type');

    switch (type) {
      case 'product_changed':
        _handleProductChanged(event.data, emit);
        break;
      case 'operation_status':
        _handleOperationStatus(event.data, emit);
        break;
      case 'operation_completed':
        _handleOperationCompleted(event.data, emit);
        break;
      default:
        emit(ColocacionRealtimeUpdate(
          type: type ?? 'unknown',
          data: event.data,
          timestamp: DateTime.now(),
        ));
    }
  }

  /// Reinicializar estado
  void _onReset(
    ColocacionReset event,
    Emitter<ColocacionState> emit,
  ) {
    emit(ColocacionInitial());
  }

  /// Manejar cambio de producto (WebSocket)
  void _handleProductChanged(
    Map<String, dynamic> data,
    Emitter<ColocacionState> emit,
  ) {
    // Notificar que un producto cambió en tiempo real
    emit(ColocacionRealtimeUpdate(
      type: 'product_changed',
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  /// Manejar estado de operación (WebSocket)
  void _handleOperationStatus(
    Map<String, dynamic> data,
    Emitter<ColocacionState> emit,
  ) {
    // Actualizar estado de operación pendiente
    emit(ColocacionRealtimeUpdate(
      type: 'operation_status',
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  /// Manejar operación completada (WebSocket)
  void _handleOperationCompleted(
    Map<String, dynamic> data,
    Emitter<ColocacionState> emit,
  ) {
    // Notificar que una operación se completó
    emit(ColocacionRealtimeUpdate(
      type: 'operation_completed',
      data: data,
      timestamp: DateTime.now(),
    ));
  }
}
