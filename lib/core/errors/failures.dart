import 'package:equatable/equatable.dart';

/// Clase base para los fallos en la aplicación
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Fallo específico para errores de servidor
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Fallo específico para errores de caché
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Fallo específico para errores de red
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Fallo específico para errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Fallo específico para errores inesperados
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message);
}

/// Fallo específico para errores de dispositivo (escáner, impresora)
class DeviceFailure extends Failure {
  const DeviceFailure(String message) : super(message);
}
