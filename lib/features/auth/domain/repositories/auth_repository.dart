import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String otpCode,
  });

  Future<Either<Failure, User>> socialLogin({
    required String provider,
    required String token,
    String? name,
    String? email,
  });

  Future<Either<Failure, Unit>> sendRegisterOtp({
    required String email,
  });

  Future<Either<Failure, Unit>> sendForgotOtp({
    required String email,
  });

  Future<Either<Failure, User>> verifyOtp({
    required String email,
    required String otpCode,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  });
}
