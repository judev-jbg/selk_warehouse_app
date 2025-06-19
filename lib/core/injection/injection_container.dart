// lib/core/injection/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:selk_warehouse_app/features/colocacion/data/datasources/colocacion_local_datasource.dart';
import 'package:selk_warehouse_app/features/colocacion/data/datasources/colocacion_remote_datasource.dart';
import 'package:selk_warehouse_app/features/colocacion/data/repositories/colocacion_repository_impl.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/repositories/colocacion_repository.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/usecases/create_label.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/usecases/get_pending_labels.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/usecases/mark_labels_as_printed.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/usecases/search_product_by_barcode.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/usecases/update_product_location.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/usecases/update_product_stock.dart';
import 'package:selk_warehouse_app/features/colocacion/presentation/bloc/colocacion_bloc.dart';

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
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  //! Features
  _initAuth();
  _initColocacion();

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

void _initColocacion() {
  // Use cases
  sl.registerLazySingleton(() => SearchProductByBarcode(sl()));
  sl.registerLazySingleton(() => UpdateProductLocation(sl()));
  sl.registerLazySingleton(() => UpdateProductStock(sl()));
  sl.registerLazySingleton(() => CreateLabel(sl()));
  sl.registerLazySingleton(() => GetPendingLabels(sl()));
  sl.registerLazySingleton(() => MarkLabelsAsPrinted(sl()));

  // Repository
  sl.registerLazySingleton<ColocacionRepository>(
    () => ColocacionRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ColocacionRemoteDataSource>(
    () => ColocacionRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<ColocacionLocalDataSource>(
    () => ColocacionLocalDataSourceImpl(databaseHelper: sl()),
  );

  // BLoC
  sl.registerFactory(() => ColocacionBloc(
        searchProductByBarcode: sl(),
        updateProductLocation: sl(),
        updateProductStock: sl(),
        createLabel: sl(),
        getPendingLabels: sl(),
        markLabelsAsPrinted: sl(),
        repository: sl(),
        logger: sl(),
      ));
}
