import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/account_entities.dart';
import '../repositories/account_repository.dart';

class GetProfileUseCase {
  final AccountRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getProfile();
  }
}
