import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/api_validation_repository.dart';

class ValidateApiKeyUseCase {
  final ApiValidationRepository repository;

  ValidateApiKeyUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.validateApiKey();
  }
}
