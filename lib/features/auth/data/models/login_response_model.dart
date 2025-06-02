// lib/features/auth/data/models/login_response_model.dart
import '../../domain/entities/login_response.dart';
import 'user_model.dart';

class LoginResponseModel extends LoginResponse {
  const LoginResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.user,
    required super.expiresAt,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': (user as UserModel).toJson(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  factory LoginResponseModel.fromEntity(LoginResponse response) {
    return LoginResponseModel(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      user: UserModel.fromEntity(response.user),
      expiresAt: response.expiresAt,
    );
  }
}
