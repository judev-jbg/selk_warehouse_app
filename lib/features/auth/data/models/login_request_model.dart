// lib/features/auth/data/models/login_request_model.dart
import '../../domain/entities/login_request.dart';

class LoginRequestModel extends LoginRequest {
  const LoginRequestModel({
    required super.username,
    required super.password,
    required super.deviceIdentifier,
  });

  factory LoginRequestModel.fromEntity(LoginRequest request) {
    return LoginRequestModel(
      username: request.username,
      password: request.password,
      deviceIdentifier: request.deviceIdentifier,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'device_identifier': deviceIdentifier,
    };
  }

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      username: json['username'] as String,
      password: json['password'] as String,
      deviceIdentifier: json['device_identifier'] as String,
    );
  }
}
