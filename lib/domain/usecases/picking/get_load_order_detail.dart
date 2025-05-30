import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/load_order.dart';
import '../../repositories/picking_repository.dart';
import '../usecase.dart';

class GetLoadOrderDetailParams {
  final String loadOrderId;

  GetLoadOrderDetailParams({required this.loadOrderId});
}

class GetLoadOrderDetail
    implements UseCase<LoadOrder, GetLoadOrderDetailParams> {
  final PickingRepository repository;

  GetLoadOrderDetail(this.repository);

  @override
  Future<Either<Failure, LoadOrder>> call(
    GetLoadOrderDetailParams params,
  ) async {
    return await repository.getLoadOrderDetail(params.loadOrderId);
  }
}
