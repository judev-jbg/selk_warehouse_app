import 'package:equatable/equatable.dart';

/// Entidad que representa a un usuario en el sistema
class User extends Equatable {
  final int id;
  final String username;
  final String name;
  final List<String> roles;
  final String token;
  final String? refreshToken;

  const User({
    required this.id,
    required this.username,
    required this.name,
    required this.roles,
    required this.token,
    this.refreshToken,
  });

  /// Verifica si el usuario tiene un rol específico
  bool hasRole(String role) => roles.contains(role);

  @override
  List<Object?> get props => [id, username, roles];
}
