// lib/features/auth/data/models/user_model.dart
import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.odooUserId,
    required super.username,
    required super.email,
    required super.fullName,
    required super.isActive,
    required super.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      odooUserId: json['odoo_user_id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      isActive: json['is_active'] as bool,
      permissions: UserPermissionsModel.fromJson(
          json['permissions'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'odoo_user_id': odooUserId,
      'username': username,
      'email': email,
      'full_name': fullName,
      'is_active': isActive,
      'permissions': (permissions as UserPermissionsModel).toJson(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      odooUserId: user.odooUserId,
      username: user.username,
      email: user.email,
      fullName: user.fullName,
      isActive: user.isActive,
      permissions: UserPermissionsModel.fromEntity(user.permissions),
    );
  }

  /// Para almacenamiento en SQLite
  factory UserModel.fromDatabase(Map<String, dynamic> dbRow) {
    return UserModel(
      id: dbRow['id'] as String,
      odooUserId: dbRow['odoo_user_id'] as int,
      username: dbRow['username'] as String,
      email: dbRow['email'] as String,
      fullName: dbRow['full_name'] as String,
      isActive: (dbRow['is_active'] as int) == 1,
      permissions: UserPermissionsModel.fromJson(
          json.decode(dbRow['permissions'] as String) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'odoo_user_id': odooUserId,
      'username': username,
      'email': email,
      'full_name': fullName,
      'is_active': isActive ? 1 : 0,
      'permissions':
          json.encode((permissions as UserPermissionsModel).toJson()),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'last_sync': DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    int? odooUserId,
    String? username,
    String? email,
    String? fullName,
    bool? isActive,
    UserPermissions? permissions,
  }) {
    return UserModel(
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

class UserPermissionsModel extends UserPermissions {
  const UserPermissionsModel({
    required super.colocacion,
    required super.entrada,
    required super.recogida,
  });

  factory UserPermissionsModel.fromJson(Map<String, dynamic> json) {
    return UserPermissionsModel(
      colocacion: ModulePermissionModel.fromJson(
          json['colocacion'] as Map<String, dynamic>),
      entrada: ModulePermissionModel.fromJson(
          json['entrada'] as Map<String, dynamic>),
      recogida: ModulePermissionModel.fromJson(
          json['recogida'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colocacion': (colocacion as ModulePermissionModel).toJson(),
      'entrada': (entrada as ModulePermissionModel).toJson(),
      'recogida': (recogida as ModulePermissionModel).toJson(),
    };
  }

  factory UserPermissionsModel.fromEntity(UserPermissions permissions) {
    return UserPermissionsModel(
      colocacion: ModulePermissionModel.fromEntity(permissions.colocacion),
      entrada: ModulePermissionModel.fromEntity(permissions.entrada),
      recogida: ModulePermissionModel.fromEntity(permissions.recogida),
    );
  }
}

class ModulePermissionModel extends ModulePermission {
  const ModulePermissionModel({
    required super.read,
    required super.write,
    required super.admin,
  });

  factory ModulePermissionModel.fromJson(Map<String, dynamic> json) {
    return ModulePermissionModel(
      read: json['read'] as bool,
      write: json['write'] as bool,
      admin: json['admin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'read': read,
      'write': write,
      'admin': admin,
    };
  }

  factory ModulePermissionModel.fromEntity(ModulePermission permission) {
    return ModulePermissionModel(
      read: permission.read,
      write: permission.write,
      admin: permission.admin,
    );
  }
}
