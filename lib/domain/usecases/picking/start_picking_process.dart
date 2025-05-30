import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/load_order.dart';
import '../../repositories/picking_repository.dart';
import '../usecase.dart';

class StartPickingProcessParams {
  final String loadOrderId;

  StartPickingProcessParams({required this.loadOrderId});
}

class StartPickingProcess
    implements UseCase<LoadOrder, StartPickingProcessParams> {
  final PickingRepository repository;

  StartPickingProcess(this.repository);

  @override
  Future<Either<Failure, LoadOrder>> call(
    StartPickingProcessParams params,
  ) async {
    return await repository.startPickingProcess(params.loadOrderId);
  }
}
