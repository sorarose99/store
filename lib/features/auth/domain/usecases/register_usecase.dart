import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      otpCode: params.otpCode,
    );
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String otpCode;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.otpCode,
  });
}
