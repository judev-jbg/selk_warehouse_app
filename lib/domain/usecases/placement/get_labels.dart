import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/label.dart';
import '../../repositories/placement_repository.dart';

class NoParams {}

class GetLabels {
  final PlacementRepository repository;

  GetLabels(this.repository);

  Future<Either<Failure, List<Label>>> call(NoParams params) async {
    return await repository.getPendingLabels();
  }
}
