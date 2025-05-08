import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/scan.dart';
import '../../repositories/entry_repository.dart';
import '../../usecases/usecase.dart';

class ScanProductParams {
  final String barcode;
  final String? orderId;
  final String? supplierId;

  ScanProductParams({required this.barcode, this.orderId, this.supplierId});
}

class ScanProduct {
  final EntryRepository repository;

  ScanProduct(this.repository);

  Future<Either<Failure, Scan>> call(ScanProductParams params) async {
    return await repository.registerScan(
      params.barcode,
      orderId: params.orderId,
      supplierId: params.supplierId,
    );
  }
}
