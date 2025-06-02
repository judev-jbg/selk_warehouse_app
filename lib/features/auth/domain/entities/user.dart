// lib/features/auth/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final int odooUserId;
  final String username;
  final String email;
  final String fullName;
  final bool isActive;
  final UserPermissions permissions;

  const User({
    required this.id,
    required this.odooUserId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.isActive,
    required this.permissions,
  });

  @override
  List<Object?> get props => [
        id,
        odooUserId,
        username,
        email,
        fullName,
        isActive,
        permissions,
      ];

  User copyWith({
    String? id,
    int? odooUserId,
    String? username,
    String? email,
    String? fullName,
    bool? isActive,
    UserPermissions? permissions,
  }) {
    return User(
      id: id ?? this.id,
      odooUserId: odooUserId ?? this.odooUserId,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }
}

class UserPermissions extends Equatable {
  final ModulePermission colocacion;
  final ModulePermission entrada;
  final ModulePermission recogida;

  const UserPermissions({
    required this.colocacion,
    required this.entrada,
    required this.recogida,
  });

  @override
  List<Object?> get props => [colocacion, entrada, recogida];

  UserPermissions copyWith({
    ModulePermission? colocacion,
    ModulePermission? entrada,
    ModulePermission? recogida,
  }) {
    return UserPermissions(
      colocacion: colocacion ?? this.colocacion,
      entrada: entrada ?? this.entrada,
      recogida: recogida ?? this.recogida,
    );
  }

  /// Verificar si tiene permiso para un módulo específico
  bool hasPermission(String module, String level) {
    final modulePermission = _getModulePermission(module);
    if (modulePermission == null) return false;

    switch (level.toLowerCase()) {
      case 'read':
        return modulePermission.read;
      case 'write':
        return modulePermission.write;
      case 'admin':
        return modulePermission.admin;
      default:
        return false;
    }
  }

  ModulePermission? _getModulePermission(String module) {
    switch (module.toLowerCase()) {
      case 'colocacion':
        return colocacion;
      case 'entrada':
        return entrada;
      case 'recogida':
        return recogida;
      default:
        return null;
    }
  }
}

class ModulePermission extends Equatable {
  final bool read;
  final bool write;
  final bool admin;

  const ModulePermission({
    required this.read,
    required this.write,
    required this.admin,
  });

  @override
  List<Object?> get props => [read, write, admin];

  ModulePermission copyWith({
    bool? read,
    bool? write,
    bool? admin,
  }) {
    return ModulePermission(
      read: read ?? this.read,
      write: write ?? this.write,
      admin: admin ?? this.admin,
    );
  }
}
