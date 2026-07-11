import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/account_repository.dart';

class ChangePasswordUseCase {
  final AccountRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call(
      String currentPassword, String newPassword) async {
    return await repository.changePassword(currentPassword, newPassword);
  }
}
