import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/product.dart';
import '../../repositories/placement_repository.dart';

class SearchProductParams {
  final String barcode;

  SearchProductParams({required this.barcode});
}

class SearchProduct {
  final PlacementRepository repository;

  SearchProduct(this.repository);

  Future<Either<Failure, Product>> call(SearchProductParams params) async {
    return await repository.searchProductByBarcode(params.barcode);
  }
}
