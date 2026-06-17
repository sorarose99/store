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
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;

  RegisterParams({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });
}
