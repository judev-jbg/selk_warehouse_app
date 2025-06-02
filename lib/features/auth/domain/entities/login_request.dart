// lib/features/auth/domain/entities/login_request.dart
import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String username;
  final String password;
  final String deviceIdentifier;

  const LoginRequest({
    required this.username,
    required this.password,
    required this.deviceIdentifier,
  });

  @override
  List<Object?> get props => [username, password, deviceIdentifier];

  LoginRequest copyWith({
    String? username,
    String? password,
    String? deviceIdentifier,
  }) {
    return LoginRequest(
      username: username ?? this.username,
      password: password ?? this.password,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
    );
  }
}
