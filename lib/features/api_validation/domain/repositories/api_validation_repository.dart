import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ApiValidationRepository {
  Future<Either<Failure, void>> validateApiKey();
}
