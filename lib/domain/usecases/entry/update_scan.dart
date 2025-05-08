import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/scan.dart';
import '../../repositories/entry_repository.dart';
import '../../usecases/usecase.dart';

class UpdateScanParams {
  final String scanId;
  final double newQuantity;

  UpdateScanParams({required this.scanId, required this.newQuantity});
}

class UpdateScan {
  final EntryRepository repository;

  UpdateScan(this.repository);

  Future<Either<Failure, Scan>> call(UpdateScanParams params) async {
    return await repository.updateScanQuantity(
      params.scanId,
      params.newQuantity,
    );
  }
}
