import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Clase que no requiere parámetros para casos de uso
class NoParams {}

/// Interfaz genérica para todos los casos de uso
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
