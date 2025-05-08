import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/entry_repository.dart';
import '../../usecases/usecase.dart';

class DeleteScanParams {
  final String scanId;

  DeleteScanParams({required this.scanId});
}

class DeleteScan {
  final EntryRepository repository;

  DeleteScan(this.repository);

  Future<Either<Failure, void>> call(DeleteScanParams params) async {
    return await repository.deleteScan(params.scanId);
  }
}
