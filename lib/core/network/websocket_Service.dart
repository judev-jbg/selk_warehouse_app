import 'dart:async';
import 'dart:convert';
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
}

/// Servicio para la comunicación en tiempo real mediante WebSockets
class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<WSEvent>? _eventsController;
  bool _isConnected = false;
  String? _authToken;
  Timer? _pingTimer;

  /// Establece el token de autenticación para el WebSocket
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Conexión al servidor WebSocket
  Future<bool> connect() async {
    if (_isConnected) {
      return true;
    }

    try {
      final uri = Uri.parse('${ApiConstants.wsUrl}?token=$_authToken');
      _channel = IOWebSocketChannel.connect(uri);
      _eventsController = StreamController<WSEvent>.broadcast();

      // Suscripción al stream del canal para procesar eventos
      _channel!.stream.listen(
        (dynamic data) {
          if (data is String) {
            try {
              final jsonData = json.decode(data);
              final event = WSEvent.fromJson(jsonData);
              _eventsController?.add(event);
            } catch (e) {
              print('Error al procesar mensaje WebSocket: $e');
            }
          }
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          _eventsController?.addError(error);
          disconnect();
        },
        onDone: () {
          print('Conexión WebSocket cerrada');
          disconnect();
        },
      );

      _isConnected = true;

      // Iniciar ping periódico para mantener la conexión activa
      _startPingTimer();

      return true;
    } catch (e) {
      print('Error al conectar WebSocket: $e');
      _isConnected = false;
      return false;
    }
  }

  /// Desconexión del servidor WebSocket
  void disconnect() {
    _stopPingTimer();
    _channel?.sink.close();
    _eventsController?.close();
    _channel = null;
    _eventsController = null;
    _isConnected = false;
  }

  /// Envío de un evento al servidor WebSocket
  Future<bool> sendEvent(WSEvent event) async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) {
        return false;
      }
    }

    try {
      _channel!.sink.add(json.encode(event.toJson()));
      return true;
    } catch (e) {
      print('Error al enviar evento WebSocket: $e');
      return false;
    }
  }

  /// Stream de eventos recibidos
  Stream<WSEvent> get events => _eventsController?.stream ?? Stream.empty();

  /// Verifica si está conectado al servidor WebSocket
  bool get isConnected => _isConnected;

  /// Inicia un temporizador para enviar pings periódicos al servidor
  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
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
