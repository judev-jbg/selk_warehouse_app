import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../constants/api_constants.dart';

/// Tipo de evento WebSocket
enum WSEventType {
  scan,
  labelPrint,
  locationUpdate,
  stockUpdate,
  deliveryNote,
  error,
}

/// Clase que representa un evento de WebSocket
class WSEvent {
  final WSEventType type;
  final Map<String, dynamic> data;

  WSEvent({required this.type, required this.data});

  factory WSEvent.fromJson(Map<String, dynamic> json) {
    return WSEvent(type: _parseEventType(json['type']), data: json['data']);
  }

  static WSEventType _parseEventType(String typeStr) {
    switch (typeStr) {
      case 'scan':
        return WSEventType.scan;
      case 'labelPrint':
        return WSEventType.labelPrint;
      case 'locationUpdate':
        return WSEventType.locationUpdate;
      case 'stockUpdate':
        return WSEventType.stockUpdate;
      case 'deliveryNote':
        return WSEventType.deliveryNote;
      default:
        return WSEventType.error;
    }
  }

  Map<String, dynamic> toJson() {
    return {'type': type.toString().split('.').last, 'data': data};
  }

  @override
  String toString() {
    return 'WSEvent{type: $type, data: $data}';
  }
}

/// Servicio para la comunicación en tiempo real mediante WebSockets
abstract class WebSocketService {
  Stream<WSEvent> get events;
  Future<bool> connect();
  void disconnect();
  Future<bool> sendEvent(WSEvent event);
  void setAuthToken(String token);
  bool get isConnected;
}

class WebSocketServiceImpl implements WebSocketService {
  final _eventsController = StreamController<WSEvent>.broadcast();
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _authToken;
  Timer? _pingTimer;
  String _wsUrl;

  WebSocketServiceImpl(this._wsUrl);

  /// Establece el token de autenticación para el WebSocket
  @override
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Conexión al servidor WebSocket
  @override
  Future<bool> connect() async {
    if (_isConnected) {
      return true;
    }

    try {
      final uri = Uri.parse('$_wsUrl?token=$_authToken');
      debugPrint('Conectando a WebSocket: $uri');
      _channel = IOWebSocketChannel.connect(uri);

      // Suscripción al stream del canal para procesar eventos
      _channel!.stream.listen(
        (dynamic data) {
          if (data is String) {
            try {
              debugPrint('WebSocket recibido: $data');
              final jsonData = json.decode(data);
              final event = WSEvent.fromJson(jsonData);
              _eventsController.add(event);
            } catch (e) {
              debugPrint('Error al procesar mensaje WebSocket: $e');
            }
          }
        },
        onError: (error) {
          debugPrint('Error en WebSocket: $error');
          _eventsController.addError(error);
          disconnect();
        },
        onDone: () {
          debugPrint('Conexión WebSocket cerrada');
          disconnect();
        },
      );

      _isConnected = true;

      // Iniciar ping periódico para mantener la conexión activa
      _startPingTimer();

      debugPrint('Conexión WebSocket establecida');
      return true;
    } catch (e) {
      debugPrint('Error al conectar WebSocket: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Desconexión del servidor WebSocket
  @override
  void disconnect() {
    _stopPingTimer();
    _channel?.sink.close();
    _isConnected = false;
    debugPrint('WebSocket desconectado');
  }

  /// Envío de un evento al servidor WebSocket
  @override
  Future<bool> sendEvent(WSEvent event) async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) {
        return false;
      }
    }

    try {
      final jsonData = json.encode(event.toJson());
      debugPrint('WebSocket enviando: $jsonData');
      _channel!.sink.add(jsonData);
      return true;
    } catch (e) {
      debugPrint('Error al enviar evento WebSocket: $e');
      return false;
    }
  }

  /// Stream de eventos recibidos
  @override
  Stream<WSEvent> get events => _eventsController.stream;

  /// Verifica si está conectado al servidor WebSocket
  @override
  bool get isConnected => _isConnected;

  /// Inicia un temporizador para enviar pings periódicos al servidor
  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        debugPrint('Enviando ping al servidor WebSocket');
        _channel?.sink.add('ping');
      } else {
        _stopPingTimer();
      }
    });
  }

  /// Detiene el temporizador de ping
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }
}

// Implementación Mock para pruebas
class MockWebSocketService implements WebSocketService {
  final _eventsController = StreamController<WSEvent>.broadcast();
  bool _isConnected = true;

  @override
  Stream<WSEvent> get events => _eventsController.stream;

  @override
  Future<bool> connect() async {
    debugPrint('Mock WebSocket: Conectando');
    _isConnected = true;
    return true;
  }

  @override
  void disconnect() {
    debugPrint('Mock WebSocket: Desconectando');
    _isConnected = false;
  }

  @override
  Future<bool> sendEvent(WSEvent event) async {
    debugPrint('Mock WebSocket enviando evento: ${event.toString()}');
    _eventsController.add(event);
    return true;
  }

  @override
  void setAuthToken(String token) {
    debugPrint('Mock WebSocket: Token establecido: $token');
  }

  @override
  bool get isConnected => _isConnected;
}
