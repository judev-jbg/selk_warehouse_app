// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

/// Fallo base de la aplicación
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Fallo de servidor
class ServerFailure extends Failure {
  const ServerFailure(String message, [String? code]) : super(message, code);
}

/// Fallo de caché
class CacheFailure extends Failure {
  const CacheFailure(String message, [String? code]) : super(message, code);
}

/// Fallo de red
class NetworkFailure extends Failure {
  const NetworkFailure(String message, [String? code]) : super(message, code);
}

/// Fallo de autenticación
class AuthFailure extends Failure {
  const AuthFailure(String message, [String? code]) : super(message, code);
}

/// Fallo de validación
class ValidationFailure extends Failure {
  const ValidationFailure(String message, [String? code])
      : super(message, code);
}
