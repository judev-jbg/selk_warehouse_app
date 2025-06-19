import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/operation_result.dart';
import '../repositories/colocacion_repository.dart';

class UpdateProductStock
    implements UseCase<OperationResult, UpdateStockParams> {
  final ColocacionRepository repository;

  UpdateProductStock(this.repository);

  @override
  Future<Either<Failure, OperationResult>> call(
      UpdateStockParams params) async {
    // Validar parámetros
    if (params.productId <= 0) {
      return const Left(ValidationFailure('ID de producto inválido'));
    }

    // Validar stock
    final stockValidation = _validateStock(params.newStock);
    if (!stockValidation.isValid) {
      return Left(ValidationFailure(stockValidation.error!));
    }

    return await repository.updateProductStock(
      params.productId,
      stockValidation.cleanStock!,
    );
  }

  /// Validar valor de stock
  StockValidationResult _validateStock(double stock) {
    // Verificar que no sea negativo
    if (stock < 0) {
      return const StockValidationResult(
        isValid: false,
        error: 'El stock no puede ser negativo',
      );
    }

    // Verificar límite máximo
    const maxStock = 999999.99;
    if (stock > maxStock) {
      return StockValidationResult(
        isValid: false,
        error: 'Stock excede el límite máximo ($maxStock)',
      );
    }

    // Verificar máximo 2 decimales
    final decimalPlaces = _countDecimals(stock);
    if (decimalPlaces > 2) {
      return const StockValidationResult(
        isValid: false,
        error: 'El stock puede tener máximo 2 decimales',
      );
    }

    // Redondear a 2 decimales
    final cleanStock = double.parse(stock.toStringAsFixed(2));

    return StockValidationResult(
      isValid: true,
      cleanStock: cleanStock,
    );
  }

  /// Contar decimales de un número
  int _countDecimals(double value) {
    if (value == value.truncateToDouble()) return 0;
    final str = value.toString();
    if (str.contains('.')) {
      return str.split('.')[1].length;
    }
    return 0;
  }
}

class UpdateStockParams {
  final int productId;
  final double newStock;

  const UpdateStockParams({
    required this.productId,
    required this.newStock,
  });
}

class StockValidationResult {
  final bool isValid;
  final double? cleanStock;
  final String? error;

  const StockValidationResult({
    required this.isValid,
    this.cleanStock,
    this.error,
  });
}
