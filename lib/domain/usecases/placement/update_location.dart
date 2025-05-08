import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/product.dart';
import '../../repositories/placement_repository.dart';

class UpdateLocationParams {
  final String productId;
  final String newLocation;

  UpdateLocationParams({required this.productId, required this.newLocation});
}

class UpdateLocation {
  final PlacementRepository repository;

  UpdateLocation(this.repository);

  Future<Either<Failure, Product>> call(UpdateLocationParams params) async {
    return await repository.updateProductLocation(
      params.productId,
      params.newLocation,
    );
  }
}
