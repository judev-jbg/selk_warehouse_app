import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

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
    final jsonString = sharedPreferences.getString(StorageConstants.cachedUser);

    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException('No hay usuario en caché');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences
        .setString(StorageConstants.cachedUser, json.encode(user.toJson()))
        .then((success) {
          if (!success) {
            throw CacheException('Error al guardar usuario en caché');
          }
        });
  }

  @override
  Future<void> clearUser() {
    return sharedPreferences.remove(StorageConstants.cachedUser).then((
      success,
    ) {
      if (!success) {
        throw CacheException('Error al eliminar usuario de caché');
      }
    });
  }
}
