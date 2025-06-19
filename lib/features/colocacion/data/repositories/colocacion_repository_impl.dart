import 'package:dartz/dartz.dart';
import 'package:selk_warehouse_app/features/colocacion/domain/entities/label.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_search_result.dart';
import '../../domain/entities/operation_result.dart';
import '../../domain/repositories/colocacion_repository.dart';
import '../datasources/colocacion_remote_datasource.dart';
import '../datasources/colocacion_local_datasource.dart';
import '../models/product_model.dart';
import '../models/operation_result_model.dart';

class ColocacionRepositoryImpl implements ColocacionRepository {
  final ColocacionRemoteDataSource remoteDataSource;
  final ColocacionLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ColocacionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProductSearchResult>> searchProductByBarcode(
    String barcode, {
    bool useCache = true,
  }) async {
    try {
      // 1. Verificar cache local primero si está habilitado
      if (useCache) {
        try {
          final cachedProduct = await localDataSource.getCachedProduct(barcode);
          if (cachedProduct != null) {
            return Right(ProductSearchResult(
              found: true,
              product: cachedProduct,
              cached: true,
              searchTime: 0,
              timestamp: DateTime.now(),
            ));
          }
        } catch (e) {
          // Si falla el cache local, continuar con búsqueda remota
        }
      }

      // 2. Verificar conectividad
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('Sin conexión a internet'));
      }

      // 3. Buscar en servidor remoto
      final searchResult = await remoteDataSource.searchProductByBarcode(
        barcode,
        useCache: useCache,
      );

      // 4. Guardar en cache local si encontró producto
      if (searchResult.found && searchResult.product != null) {
        try {
          await localDataSource.cacheProduct(
            ProductModel.fromEntity(searchResult.product!),
          );
        } catch (e) {
          // No fallar la búsqueda si falla el cache
        }
      }

      return Right(searchResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OperationResult>> updateProductLocation(
    int productId,
    String newLocation,
  ) async {
    try {
      // 1. Verificar conectividad
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('Sin conexión a internet'));
      }

      // 2. Realizar actualización remota (con optimistic update)
      final operationResult = await remoteDataSource.updateProductLocation(
        productId,
        newLocation,
      );

      // 3. Guardar operación en base de datos local para tracking
      try {
        await localDataSource.saveOperationResult(
          OperationResultExtension.fromEntity(operationResult),
        );
      } catch (e) {
        // No fallar la operación si falla el guardado local
      }

      // 4. Si la respuesta contiene producto actualizado, actualizar cache
      if (operationResult.product != null) {
        try {
          await localDataSource.cacheProduct(
            ProductModel.fromEntity(operationResult.product!),
          );
        } catch (e) {
          // No fallar la operación si falla el cache
        }
      }

      return Right(operationResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OperationResult>> updateProductStock(
    int productId,
    double newStock,
  ) async {
    try {
      // 1. Verificar conectividad
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('Sin conexión a internet'));
      }

      // 2. Realizar actualización remota (con optimistic update)
      final operationResult = await remoteDataSource.updateProductStock(
        productId,
        newStock,
      );

      // 3. Guardar operación en base de datos local para tracking
      try {
        await localDataSource.saveOperationResult(
          OperationResultExtension.fromEntity(operationResult),
        );
      } catch (e) {
        // No fallar la operación si falla el guardado local
      }

      // 4. Si la respuesta contiene producto actualizado, actualizar cache
      if (operationResult.product != null) {
        try {
          await localDataSource.cacheProduct(
            ProductModel.fromEntity(operationResult.product!),
          );
        } catch (e) {
          // No fallar la operación si falla el cache
        }
      }

      return Right(operationResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Product>> getCachedProduct(String barcode) async {
    try {
      final cachedProduct = await localDataSource.getCachedProduct(barcode);
      if (cachedProduct != null) {
        return Right(cachedProduct);
      } else {
        return const Left(CacheFailure('Producto no encontrado en cache'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, e.code));
    } catch (e) {
      return Left(CacheFailure(
          'Error obteniendo producto desde cache: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheProduct(Product product) async {
    try {
      await localDataSource.cacheProduct(ProductModel.fromEntity(product));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, e.code));
    } catch (e) {
      return Left(
          CacheFailure('Error guardando producto en cache: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<OperationResult>>> getPendingOperations() async {
    try {
      List<OperationResult> allOperations = [];

      // 1. Obtener operaciones pendientes locales
      try {
        final localOperations = await localDataSource.getPendingOperations();
        allOperations.addAll(localOperations);
      } catch (e) {
        // Si falla local, continuar con remoto
      }

      // 2. Si hay conexión, obtener operaciones pendientes remotas
      if (await networkInfo.isConnected) {
        try {
          final remoteOperations =
              await remoteDataSource.getPendingOperations();

          // Evitar duplicados comparando por operationId
          for (final remoteOp in remoteOperations) {
            if (!allOperations
                .any((op) => op.operationId == remoteOp.operationId)) {
              allOperations.add(remoteOp);
            }
          }
        } catch (e) {
          // Si falla remoto, usar solo locales
        }
      }

      return Right(allOperations);
    } catch (e) {
      return Left(ServerFailure(
          'Error obteniendo operaciones pendientes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, OperationResult>> getOperationStatus(
      String operationId) async {
    try {
      // 1. Verificar conectividad
      if (!await networkInfo.isConnected) {
        return const Left(NetworkFailure('Sin conexión a internet'));
      }

      // 2. Obtener estado desde servidor
      final operationResult =
          await remoteDataSource.getOperationStatus(operationId);

      // 3. Actualizar estado en base de datos local
      try {
        await localDataSource.updateOperationStatus(
          operationId,
          operationResult.status.name,
        );
      } catch (e) {
        // No fallar la consulta si falla la actualización local
      }

      return Right(operationResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure(
          'Error obteniendo estado de operación: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> clearProductCache() async {
    try {
      await localDataSource.clearProductCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, e.code));
    } catch (e) {
      return Left(CacheFailure('Error limpiando cache: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isServerReachable() async {
    try {
      if (!await networkInfo.isConnected) {
        return false;
      }
      return await remoteDataSource.checkHealthStatus();
    } catch (e) {
      return false;
    }
  }

  /// Método para limpiar cache expirado (llamar periódicamente)
  Future<void> cleanExpiredCache() async {
    try {
      await localDataSource.cleanExpiredCache();
    } catch (e) {
      // No es crítico si falla la limpieza
    }
  }

  @override
  Future<Either<Failure, Label>> createLabel(Product product, String location) {
    // TODO: implement createLabel
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteLabels(List<String> labelIds) {
    // TODO: implement deleteLabels
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Label>>> getLabelHistory({int limit = 50}) {
    // TODO: implement getLabelHistory
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Label>>> getPendingLabels() {
    // TODO: implement getPendingLabels
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> markLabelsAsPrinted(List<String> labelIds) {
    // TODO: implement markLabelsAsPrinted
    throw UnimplementedError();
  }
}

/// Extension para convertir OperationResult a OperationResultModel
extension OperationResultExtension on OperationResult {
  static OperationResultModel fromEntity(OperationResult entity) {
    return OperationResultModel(
      operationId: entity.operationId,
      type: entity.type,
      status: entity.status,
      product: entity.product,
      message: entity.message,
      timestamp: entity.timestamp,
      error: entity.error,
    );
  }
}
