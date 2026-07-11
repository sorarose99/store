import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<User, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      email: params.email,
      otpCode: params.otpCode,
    );
  }
}

class VerifyOtpParams {
  final String email;
  final String otpCode;

  VerifyOtpParams({required this.email, required this.otpCode});
}
