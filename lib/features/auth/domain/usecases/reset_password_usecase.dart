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
      email: params.email,
      otpCode: params.otpCode,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams {
  final String email;
  final String otpCode;
  final String newPassword;

  ResetPasswordParams({
    required this.email,
    required this.otpCode,
    required this.newPassword,
  });
}
