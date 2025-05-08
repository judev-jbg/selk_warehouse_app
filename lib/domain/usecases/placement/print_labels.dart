import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/label.dart';
import '../../repositories/placement_repository.dart';

class PrintLabelsParams {
  final List<String> labelIds;

  PrintLabelsParams({required this.labelIds});
}

class PrintLabels {
  final PlacementRepository repository;

  PrintLabels(this.repository);

  Future<Either<Failure, List<Label>>> call(PrintLabelsParams params) async {
    return await repository.printLabels(params.labelIds);
  }
}
