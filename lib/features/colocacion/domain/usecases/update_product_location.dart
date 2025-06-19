import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/operation_result.dart';
import '../repositories/colocacion_repository.dart';

class UpdateProductLocation
    implements UseCase<OperationResult, UpdateLocationParams> {
  final ColocacionRepository repository;

  UpdateProductLocation(this.repository);

  @override
  Future<Either<Failure, OperationResult>> call(
      UpdateLocationParams params) async {
    // Validar parámetros
    if (params.productId <= 0) {
      return const Left(ValidationFailure('ID de producto inválido'));
    }

    if (params.newLocation.trim().isEmpty) {
      return const Left(ValidationFailure('Localización requerida'));
    }

    // Validar formato de localización
    final locationValidation = _validateLocationFormat(params.newLocation);
    if (!locationValidation.isValid) {
      return Left(ValidationFailure(locationValidation.error!));
    }

    return await repository.updateProductLocation(
      params.productId,
      locationValidation.cleanLocation!,
    );
  }

  /// Validar formato de localización [A-Z][0-9][0-5]
  LocationValidationResult _validateLocationFormat(String location) {
    final cleanLocation = location.trim().toUpperCase();

    // Patrón: Letra + 2 dígitos + dígito 0-5
    final pattern = RegExp(r'^[A-Z][0-9]{2}[0-5]$');

    if (!pattern.hasMatch(cleanLocation)) {
      return LocationValidationResult(
        isValid: false,
        error: 'Formato inválido. Use: [A-Z][00-99][0-5] (ej: A105)',
      );
    }

    // Validaciones adicionales (opcional)
    final aisle = cleanLocation[0];
    final block = int.parse(cleanLocation.substring(1, 3));
    final height = int.parse(cleanLocation[3]);

    // Validar pasillos existentes
    const validAisles = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    if (!validAisles.contains(aisle)) {
      return LocationValidationResult(
        isValid: false,
        error: 'Pasillo $aisle no existe. Válidos: ${validAisles.join(', ')}',
      );
    }

    return LocationValidationResult(
      isValid: true,
      cleanLocation: cleanLocation,
    );
  }
}

class UpdateLocationParams {
  final int productId;
  final String newLocation;

  const UpdateLocationParams({
    required this.productId,
    required this.newLocation,
  });
}

class LocationValidationResult {
  final bool isValid;
  final String? cleanLocation;
  final String? error;

  const LocationValidationResult({
    required this.isValid,
    this.cleanLocation,
    this.error,
  });
}
