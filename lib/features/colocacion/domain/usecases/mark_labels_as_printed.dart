// lib/features/colocacion/domain/usecases/mark_labels_as_printed.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/colocacion_repository.dart';

class MarkLabelsAsPrinted implements UseCase<void, MarkLabelsParams> {
  final ColocacionRepository repository;

  MarkLabelsAsPrinted(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkLabelsParams params) async {
    if (params.labelIds.isEmpty) {
      return const Left(ValidationFailure('No hay etiquetas seleccionadas'));
    }

    return await repository.markLabelsAsPrinted(params.labelIds);
  }
}

class MarkLabelsParams {
  final List<String> labelIds;

  const MarkLabelsParams({required this.labelIds});
}
