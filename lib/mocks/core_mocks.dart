import 'dart:async';
import 'package:dartz/dartz.dart';
import '../core/errors/failures.dart';
import '../core/network/websocket_service.dart';

// Clase base para fallos mock
class MockFailure extends Failure {
  MockFailure(String message) : super(message);
}

// Clase para fallos de producto no encontrado
class ProductNotFoundFailure extends MockFailure {
  ProductNotFoundFailure(String message) : super(message);
}

// Clase para fallos de producto no pedido
class ProductNotOrderedFailure extends MockFailure {
  final dynamic product;

  ProductNotOrderedFailure({required String message, this.product})
    : super(message);
}

// Mock del servicio WebSocket
class MockWebSocketService implements WebSocketService {
  final _eventsController = StreamController<WSEvent>.broadcast();

  @override
  Stream<WSEvent> get events => _eventsController.stream;

  @override
  Future<bool> connect() async {
    return true;
  }

  @override
  void disconnect() {}

  @override
  Future<bool> sendEvent(WSEvent event) async {
    _eventsController.add(event);
    return true;
  }

  @override
  void setAuthToken(String token) {}

  @override
  bool get isConnected => true;
}

// Clase NoParams para casos de uso
class NoParams {}
