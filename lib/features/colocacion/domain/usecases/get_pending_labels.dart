// lib/features/colocacion/domain/usecases/get_pending_labels.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/label.dart';
import '../repositories/colocacion_repository.dart';

class GetPendingLabels implements UseCase<List<Label>, NoParams> {
  final ColocacionRepository repository;

  GetPendingLabels(this.repository);

  @override
  Future<Either<Failure, List<Label>>> call(NoParams params) async {
    return await repository.getPendingLabels();
  }
}
