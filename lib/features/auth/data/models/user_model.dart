import '../../domain/entities/user.dart';

/// Modelo de datos para el usuario
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.roles,
    required super.token,
    super.refreshToken,
  });

  /// Crea un UserModel desde un mapa JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      roles: List<String>.from(json['roles']),
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  /// Convierte el UserModel a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'roles': roles,
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}
