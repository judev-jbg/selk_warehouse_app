import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/order_line.dart';
import '../../repositories/picking_repository.dart';
import '../usecase.dart';

class GetPickedItemsParams {
  final String loadOrderId;

  GetPickedItemsParams({required this.loadOrderId});
}

class GetPickedItems implements UseCase<List<OrderLine>, GetPickedItemsParams> {
  final PickingRepository repository;

  GetPickedItems(this.repository);

  @override
  Future<Either<Failure, List<OrderLine>>> call(
    GetPickedItemsParams params,
  ) async {
    return await repository.getPickedItems(params.loadOrderId);
  }
}
