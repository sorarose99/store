import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase implements UseCase<Unit, ForgotPasswordParams> {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ForgotPasswordParams params) {
    return repository.forgotPassword(
      phoneNumber: params.phoneNumber,
    );
  }
}

class ForgotPasswordParams {
  final String phoneNumber;

  ForgotPasswordParams({required this.phoneNumber});
}
