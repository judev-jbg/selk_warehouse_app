import '../../../../core/network/api_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_search_result_model.dart';
import '../models/operation_result_model.dart';
import '../services/websocket_service.dart';

abstract class ColocacionRemoteDataSource {
  Future<ProductSearchResultModel> searchProductByBarcode(String barcode,
      {bool useCache = true});
  Future<OperationResultModel> updateProductLocation(
      int productId, String newLocation);
  Future<OperationResultModel> updateProductStock(
      int productId, double newStock);
  Future<OperationResultModel> getOperationStatus(String operationId);
  Future<List<OperationResultModel>> getPendingOperations();
  Future<bool> checkHealthStatus();
  Future<void> initializeWebSocket();
  Stream<Map<String, dynamic>> get realtimeUpdates;
  Future<void> closeWebSocket();
}

class ColocacionRemoteDataSourceImpl implements ColocacionRemoteDataSource {
  final ApiClient apiClient;
  final WebSocketService webSocketService;

  ColocacionRemoteDataSourceImpl({
    required this.apiClient,
    required this.webSocketService,
  });

  /// Inicializar conexión WebSocket
  Future<void> initializeWebSocket() async {
    try {
      await webSocketService.connect();
    } catch (e) {
      // No fallar si WebSocket no se puede conectar
      // La app seguirá funcionando sin tiempo real
    }
  }

  /// Obtener stream de eventos en tiempo real
  Stream<Map<String, dynamic>> get realtimeUpdates =>
      webSocketService.messageStream;

  /// Cerrar conexión WebSocket
  Future<void> closeWebSocket() async {
    await webSocketService.disconnect();
  }

  @override
  Future<ProductSearchResultModel> searchProductByBarcode(
    String barcode, {
    bool useCache = true,
  }) async {
    try {
      final queryParams = {
        'barcode': barcode,
        if (!useCache) 'use_cache': 'false',
      };

      final response = await apiClient.get(
        '/colocacion/search',
        queryParameters: queryParams,
      );

      return ProductSearchResultModel.fromJson(response);
    } catch (e) {
      if (e is ServerException && e.code == '404') {
        return ProductSearchResultModel.fromError('Producto no encontrado');
      }
      throw ServerException('Error buscando producto: ${e.toString()}');
    }
  }

  @override
  Future<OperationResultModel> updateProductLocation(
    int productId,
    String newLocation,
  ) async {
    try {
      final response = await apiClient.put(
        '/colocacion/product/$productId/location',
        data: {'location': newLocation},
      );

      final result = OperationResultModel.fromUpdateResponse(response);

      // Si la operación es optimista, notificar via WebSocket
      if (result.isOptimistic) {
        webSocketService.sendMessage({
          'type': 'optimistic_update',
          'operation': {
            'id': result.operationId,
            'type': 'location_update',
            'productId': productId,
            'newValue': newLocation,
          },
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      return result;
    } catch (e) {
      throw ServerException('Error actualizando localización: ${e.toString()}');
    }
  }

  @override
  Future<OperationResultModel> updateProductStock(
    int productId,
    double newStock,
  ) async {
    try {
      final response = await apiClient.put(
        '/colocacion/product/$productId/stock',
        data: {'qty_available': newStock},
      );

      final result = OperationResultModel.fromUpdateResponse(response);

      // Si la operación es optimista, notificar via WebSocket
      if (result.isOptimistic) {
        webSocketService.sendMessage({
          'type': 'optimistic_update',
          'operation': {
            'id': result.operationId,
            'type': 'stock_update',
            'productId': productId,
            'newValue': newStock,
          },
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      return result;
    } catch (e) {
      throw ServerException('Error actualizando stock: ${e.toString()}');
    }
  }

  @override
  Future<OperationResultModel> getOperationStatus(String operationId) async {
    try {
      final response =
          await apiClient.get('/colocacion/operation/$operationId/status');

      final data = response['data'] as Map<String, dynamic>?;
      return OperationResultModel.fromWebSocket(data ?? {});
    } catch (e) {
      throw ServerException(
          'Error obteniendo estado de operación: ${e.toString()}');
    }
  }

  @override
  Future<List<OperationResultModel>> getPendingOperations() async {
    try {
      final response = await apiClient.get('/colocacion/pending-operations');

      final data = response['data'] as Map<String, dynamic>?;
      final operations = data?['pendingOperations'] as List<dynamic>? ?? [];

      return operations
          .map((op) =>
              OperationResultModel.fromWebSocket(op as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(
          'Error obteniendo operaciones pendientes: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkHealthStatus() async {
    try {
      final response = await apiClient.get('/colocacion/health');
      return response['success'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }
}
