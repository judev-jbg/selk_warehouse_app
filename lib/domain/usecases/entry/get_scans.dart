import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../usecases/usecase.dart';
import '../../entities/scan.dart';
import '../../repositories/entry_repository.dart';

class GetScans implements UseCase<List<Scan>, NoParams> {
  final EntryRepository repository;

  GetScans(this.repository);

  @override
  Future<Either<Failure, List<Scan>>> call(NoParams params) async {
    return await repository.getAllScans();
  }
}
