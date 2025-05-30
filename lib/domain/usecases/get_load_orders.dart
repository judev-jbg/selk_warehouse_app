import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/load_order.dart';
import '../repositories/picking_repository.dart';
import 'usecase.dart';

class GetLoadOrdersParams {
  final LoadOrderStatus? status;

  GetLoadOrdersParams({this.status});
}

class GetLoadOrders implements UseCase<List<LoadOrder>, GetLoadOrdersParams> {
  final PickingRepository repository;

  GetLoadOrders(this.repository);

  @override
  Future<Either<Failure, List<LoadOrder>>> call(
    GetLoadOrdersParams params,
  ) async {
    return await repository.getLoadOrders(status: params.status);
  }
}
