// lib/features/auth/domain/entities/login_response.dart
import 'package:equatable/equatable.dart';
import 'user.dart';

class LoginResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final User user;
  final DateTime expiresAt;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user, expiresAt];

  LoginResponse copyWith({
    String? accessToken,
    String? refreshToken,
    User? user,
    DateTime? expiresAt,
  }) {
    return LoginResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
