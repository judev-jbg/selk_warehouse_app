// lib/features/colocacion/domain/usecases/create_label.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/label.dart';
import '../entities/product.dart';
import '../repositories/colocacion_repository.dart';

class CreateLabel implements UseCase<Label, CreateLabelParams> {
  final ColocacionRepository repository;

  CreateLabel(this.repository);

  @override
  Future<Either<Failure, Label>> call(CreateLabelParams params) async {
    // Validar parámetros
    if (params.product.id <= 0) {
      return const Left(ValidationFailure('Producto inválido'));
    }

    if (params.location.trim().isEmpty) {
      return const Left(ValidationFailure('Localización requerida'));
    }

    return await repository.createLabel(params.product, params.location);
  }
}

class CreateLabelParams {
  final Product product;
  final String location;

  const CreateLabelParams({
    required this.product,
    required this.location,
  });
}
