import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<Unit, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      phoneNumber: params.phoneNumber,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams {
  final String phoneNumber;
  final String newPassword;

  ResetPasswordParams({required this.phoneNumber, required this.newPassword});
}
