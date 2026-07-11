import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SendRegisterOtpUseCase implements UseCase<Unit, SendRegisterOtpParams> {
  final AuthRepository repository;

  SendRegisterOtpUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendRegisterOtpParams params) {
    return repository.sendRegisterOtp(email: params.email);
  }
}

class SendRegisterOtpParams {
  final String email;

  SendRegisterOtpParams({required this.email});
}
