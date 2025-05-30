import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/customer_delivery_note.dart';
import '../../repositories/picking_repository.dart';
import '../usecase.dart';

class GenerateCustomerDeliveryNotesParams {
  final String loadOrderId;

  GenerateCustomerDeliveryNotesParams({required this.loadOrderId});
}

class GenerateCustomerDeliveryNotes
    implements
        UseCase<
          List<CustomerDeliveryNote>,
          GenerateCustomerDeliveryNotesParams
        > {
  final PickingRepository repository;

  GenerateCustomerDeliveryNotes(this.repository);

  @override
  Future<Either<Failure, List<CustomerDeliveryNote>>> call(
    GenerateCustomerDeliveryNotesParams params,
  ) async {
    return await repository.generateCustomerDeliveryNotes(params.loadOrderId);
  }
}
