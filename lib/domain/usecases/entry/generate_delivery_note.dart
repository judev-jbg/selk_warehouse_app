import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/delivery_note.dart';
import '../../repositories/entry_repository.dart';
import '../../usecases/usecase.dart';

class GenerateDeliveryNoteParams {
  final String supplierReference;
  final List<String> scanIds;

  GenerateDeliveryNoteParams({
    required this.supplierReference,
    required this.scanIds,
  });
}

class GenerateDeliveryNote {
  final EntryRepository repository;

  GenerateDeliveryNote(this.repository);

  Future<Either<Failure, DeliveryNote>> call(
    GenerateDeliveryNoteParams params,
  ) async {
    return await repository.generateDeliveryNote(
      params.supplierReference,
      params.scanIds,
    );
  }
}
