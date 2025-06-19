// lib/features/colocacion/data/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/secure_storage.dart';

class WebSocketService {
  static WebSocketService? _instance;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  final Logger _logger = Logger();
  final SecureStorage _secureStorage = SecureStorage();

  // Configuración
  static const int _heartbeatInterval = 30; // segundos
  static const int _reconnectDelay = 5; // segundos
  static const int _maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;

  WebSocketService._internal();

  factory WebSocketService() {
    _instance ??= WebSocketService._internal();
    return _instance!;
  }

  Stream<Map<String, dynamic>> get messageStream {
    _messageController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _messageController!.stream;
  }

  bool get isConnected => _isConnected;

  /// Conectar al WebSocket
  Future<void> connect() async {
    try {
      if (_isConnected) {
        _logger.w('WebSocket ya está conectado');
        return;
      }

      // Obtener tokens de autenticación
      final accessToken = await _secureStorage.getAccessToken();
      final deviceId = await _secureStorage.getDeviceId();

      if (accessToken == null || deviceId == null) {
        throw Exception('No hay tokens de autenticación disponibles');
      }

      // Construir URL del WebSocket
      final wsUrl = _getWebSocketUrl();

      _logger.i('Conectando a WebSocket: $wsUrl');

      // Crear conexión WebSocket
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
        protocols: ['json'],
      );

      // Configurar escucha de mensajes
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );

      // Enviar autenticación
      await _authenticate(accessToken, deviceId);

      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat();

      _logger.i('WebSocket conectado exitosamente');
    } catch (e) {
      _logger.e('Error conectando WebSocket: $e');
      _scheduleReconnect();
    }
  }

  /// Desconectar WebSocket
  Future<void> disconnect() async {
    _logger.i('Desconectando WebSocket');

    _isConnected = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    await _channel?.sink.close();
    _channel = null;

    await _messageController?.close();
    _messageController = null;
  }

  /// Enviar mensaje
  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      _logger.w('WebSocket no está conectado. No se puede enviar mensaje.');
      return;
    }

    try {
      final jsonMessage = json.encode(message);
      _channel!.sink.add(jsonMessage);
      _logger.d('Mensaje WebSocket enviado: $message');
    } catch (e) {
      _logger.e('Error enviando mensaje WebSocket: $e');
    }
  }

  /// Suscribirse a eventos de colocación
  void subscribeToColocacion() {
    sendMessage({
      'type': 'subscribe',
      'channel': 'colocacion',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Desuscribirse de eventos de colocación
  void unsubscribeFromColocacion() {
    sendMessage({
      'type': 'unsubscribe',
      'channel': 'colocacion',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Obtener URL del WebSocket
  String _getWebSocketUrl() {
    final baseUrl = ApiConstants.baseUrl;
    // Convertir HTTP a WS
    final wsUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    return '$wsUrl/ws';
  }

  /// Autenticar conexión WebSocket
  Future<void> _authenticate(String accessToken, String deviceId) async {
    sendMessage({
      'type': 'auth',
      'token': accessToken,
      'deviceId': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Esperar confirmación de autenticación
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Manejar mensajes recibidos
  void _onMessage(dynamic message) {
    try {
      final data = json.decode(message) as Map<String, dynamic>;
      _logger.d('Mensaje WebSocket recibido: $data');

      // Manejar tipos especiales de mensajes
      final type = data['type'] as String?;

      switch (type) {
        case 'auth_success':
          _logger.i('Autenticación WebSocket exitosa');
          subscribeToColocacion();
          break;
        case 'auth_error':
          _logger.e('Error de autenticación WebSocket: ${data['message']}');
          _scheduleReconnect();
          break;
        case 'heartbeat_ack':
          _logger.d('Heartbeat ACK recibido');
          break;
        case 'connection_status':
        case 'product_changed':
        case 'operation_status':
        case 'operation_completed':
          // Enviar evento al stream para que lo procese el BLoC
          _messageController?.add(data);
          break;
        default:
          _messageController?.add(data);
      }
    } catch (e) {
      _logger.e('Error procesando mensaje WebSocket: $e');
    }
  }

  /// Manejar errores de conexión
  void _onError(error) {
    _logger.e('Error WebSocket: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Manejar desconexión
  void _onDisconnected() {
    _logger.w('WebSocket desconectado');
    _isConnected = false;
    _heartbeatTimer?.cancel();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    } else {
      _logger.e('Se agotaron los intentos de reconexión WebSocket');
    }
  }

  /// Programar reconexión
  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;

    _reconnectAttempts++;
    final delay = _reconnectDelay * _reconnectAttempts;

    _logger.i(
        'Programando reconexión WebSocket en ${delay}s (intento $_reconnectAttempts)');

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (_reconnectAttempts <= _maxReconnectAttempts) {
        connect();
      }
    });
  }

  /// Iniciar heartbeat
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: _heartbeatInterval),
      (timer) {
        if (_isConnected) {
          sendMessage({
            'type': 'heartbeat',
            'timestamp': DateTime.now().toIso8601String(),
          });
        } else {
          timer.cancel();
        }
      },
    );
  }
}
