import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/placement_repository.dart';

class DeleteLabelParams {
  final String labelId;

  DeleteLabelParams({required this.labelId});
}

class DeleteLabel {
  final PlacementRepository repository;

  DeleteLabel(this.repository);

  Future<Either<Failure, void>> call(DeleteLabelParams params) async {
    return await repository.deleteLabel(params.labelId);
  }
}
