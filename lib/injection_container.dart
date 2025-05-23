import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:selk_warehouse_app/domain/repositories/entry_repository.dart';
import 'package:selk_warehouse_app/domain/usecases/entry/generate_delivery_note.dart';
import 'package:selk_warehouse_app/domain/usecases/entry/get_suppliers.dart';
import 'package:selk_warehouse_app/mocks/entry_mocks.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/device/sunmi_scanner_service.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/network/websocket_service.dart';
import 'data/datasources/local/auth_local_datasourse.dart';
import 'data/datasources/remote/auth_remote_datasourse.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth/login_user.dart';
import 'domain/usecases/auth/logout_user.dart';
import 'presentation/bloc/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(loginUser: sl(), logoutUser: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Registrar los casos de uso
  sl.registerLazySingleton(() => GetAllSuppliers(sl()));
  sl.registerLazySingleton(() => GenerateDeliveryNote(sl()));

  // Registrar los repositorios
  sl.registerLazySingleton<EntryRepository>(() => MockEntryRepository());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => ApiClient(sl(), sl()));
  sl.registerLazySingleton(() => SunmiScannerService());
  sl.registerLazySingleton(() => MockWebSocketService());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());
}
