import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SocialLoginUseCase implements UseCase<User, SocialLoginParams> {
  final AuthRepository repository;

  SocialLoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SocialLoginParams params) {
    return repository.socialLogin(
      provider: params.provider,
      token: params.token,
      name: params.name,
      email: params.email,
    );
  }
}

class SocialLoginParams {
  final String provider;
  final String token;
  final String? name;
  final String? email;

  SocialLoginParams({
    required this.provider,
    required this.token,
    this.name,
    this.email,
  });
}
