import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/supplier.dart';
import '../../repositories/entry_repository.dart';
import '../../usecases/usecase.dart';

class GetAllSuppliers implements UseCase<List<Supplier>, NoParams> {
  final EntryRepository repository;

  GetAllSuppliers(this.repository);

  Future<Either<Failure, List<Supplier>>> call(NoParams params) async {
    return await repository.getAllSuppliers();
  }
}
