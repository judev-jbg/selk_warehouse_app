import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/order_line.dart';
import '../../repositories/picking_repository.dart';
import '../usecase.dart';

class RegisterProductPickingParams {
  final String loadOrderId;
  final String orderLineId;
  final double quantity;
  final bool forceIncomplete;

  RegisterProductPickingParams({
    required this.loadOrderId,
    required this.orderLineId,
    required this.quantity,
    this.forceIncomplete = false,
  });
}

class RegisterProductPicking
    implements UseCase<OrderLine, RegisterProductPickingParams> {
  final PickingRepository repository;

  RegisterProductPicking(this.repository);

  @override
  Future<Either<Failure, OrderLine>> call(
    RegisterProductPickingParams params,
  ) async {
    return await repository.registerProductPicking(
      params.loadOrderId,
      params.orderLineId,
      params.quantity,
      forceIncomplete: params.forceIncomplete,
    );
  }
}
