import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<Either<Failure, Unit>> forgotPassword({
    required String phoneNumber,
  });

  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String phoneNumber,
    required String newPassword,
  });
}
