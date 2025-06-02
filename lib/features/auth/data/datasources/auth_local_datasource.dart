import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  /// Obtiene el último usuario guardado
  ///
  /// Lanza [CacheException] si no hay usuario guardado
  Future<UserModel> getLastUser();

  /// Guarda el usuario en el almacenamiento local
  ///
  /// Lanza [CacheException] si ocurre un error al guardar
  Future<void> cacheUser(UserModel user);

  /// Elimina el usuario del almacenamiento local
  ///
  /// Lanza [CacheException] si ocurre un error al eliminar
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel> getLastUser() {
    final jsonString = sharedPreferences.getString("");

    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException('No hay usuario en caché');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString("", json.encode(user.toJson())).then((
      success,
    ) {
      if (!success) {
        throw CacheException('Error al guardar usuario en caché');
      }
    });
  }

  @override
  Future<void> clearUser() {
    return sharedPreferences.remove("").then((success) {
      if (!success) {
        throw CacheException('Error al eliminar usuario de caché');
      }
    });
  }
}
