import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/account_entities.dart';
import '../repositories/account_repository.dart';

class UpdateProfileUseCase {
  final AccountRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(Map<String, dynamic> data) async {
    return await repository.updateProfile(data);
  }
}
