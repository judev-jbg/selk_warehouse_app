import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/product.dart';
import '../../repositories/placement_repository.dart';

class UpdateStockParams {
  final String productId;
  final double newStock;

  UpdateStockParams({required this.productId, required this.newStock});
}

class UpdateStock {
  final PlacementRepository repository;

  UpdateStock(this.repository);

  Future<Either<Failure, Product>> call(UpdateStockParams params) async {
    return await repository.updateProductStock(
      params.productId,
      params.newStock,
    );
  }
}
