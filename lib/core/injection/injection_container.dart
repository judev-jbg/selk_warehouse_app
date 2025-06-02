// lib/core/injection/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

// Core
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../storage/database_helper.dart';
import '../storage/secure_storage.dart';

// Auth feature
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/refresh_token.dart';
import '../../features/auth/domain/usecases/get_cached_user.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  //! Features - Auth
  _initAuth();

  //! Core
  _initCore();

  //! External
  _initExternal();
}

void _initAuth() {
  // Bloc
  sl.registerFactory(() => AuthBloc(
        loginUser: sl(),
        logoutUser: sl(),
        refreshToken: sl(),
        getCachedUser: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => RefreshToken(sl()));
  sl.registerLazySingleton(() => GetCachedUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      databaseHelper: sl(),
    ),
  );
}

void _initCore() {
  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Storage
  sl.registerLazySingleton(() => SecureStorage());
  sl.registerLazySingleton(() => DatabaseHelper());

  // API Client
  sl.registerLazySingleton(() => ApiClient(
        dio: sl(),
        logger: sl(),
      ));
}

void _initExternal() {
  // External libraries
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: false,
        ),
      ));
}
