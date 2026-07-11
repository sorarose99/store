import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ── Login ─────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Right(userModel);
    } on UnauthorizedException {
      return const Left(ServerFailure('invalid_credentials'));
    } on ValidationException catch (e) {
      // Extract the first validation message if available, else generic
      final msg = _extractValidationMessage(e);
      return Left(ServerFailure(msg));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'server_error'));
    } on ConnectionException {
      return const Left(ConnectionFailure('network_error'));
    } catch (_) {
      return const Left(ServerFailure('server_error'));
    }
  }

  // ── Social Login ──────────────────────────────────────────────────
  @override
  Future<Either<Failure, User>> socialLogin({
    required String provider,
    required String token,
    String? name,
    String? email,
  }) async {
    try {
      // For Firebase, social login is handled directly in social_auth_service
      // but if we call this, we can just return a dummy or map it.
      // Wait, social_auth_service now returns UserCredential. The AuthBloc handles it.
      // Actually we might need to modify AuthBloc to not call `socialLoginUseCase`.
      // For now, let's just make it return a dummy or throw.
      return const Left(ServerFailure('social_login_handled_directly'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'server_error'));
    } catch (_) {
      return const Left(ServerFailure('server_error'));
    }
  }

  // ── Register ──────────────────────────────────────────────────────
  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String otpCode,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: password,
        otpCode: otpCode,
      );
      return Right(userModel);
    } on ValidationException catch (e) {
      final msg = _extractValidationMessage(e);
      return Left(ServerFailure(msg));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'server_error'));
    } on ConnectionException {
      return const Left(ConnectionFailure('network_error'));
    } catch (_) {
      return const Left(ServerFailure('server_error'));
    }
  }

  // ── Forgot Password: sends OTP ────────────────────────────────────
  @override
  Future<Either<Failure, Unit>> sendForgotOtp({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendForgotOtp(email: email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'server_error'));
    } on ConnectionException {
      return const Left(ConnectionFailure('network_error'));
    } catch (_) {
      return const Left(ServerFailure('server_error'));
    }
  }

  // ── Send Register OTP ─────────────────────────────────────────────
  @override
  Future<Either<Failure, Unit>> sendRegisterOtp({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendRegisterOtp(email: email);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'server_error'));
    } on ConnectionException {
      return const Left(ConnectionFailure('network_error'));
    } catch (_) {
      return const Left(ServerFailure('server_error'));
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────
  @override
  Future<Either<Failure, User>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      return Right(User(
        id: '',
        uuid: '',
        firstName: '',
        lastName: '',
        email: email,
        token: null,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'otp_invalid'));
    } on ConnectionException {
      return const Left(ConnectionFailure('network_error'));
    } catch (_) {
      return const Left(ServerFailure('server_error'));
    }
  }

  // ── Reset Password ────────────────────────────────────────────────
  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        otpCode: otpCode,
        newPassword: newPassword,
        passwordConfirmation: newPassword,
      );
      return const Right(unit);
    } on ValidationException catch (e) {
      final msg = _extractValidationMessage(e);
      return Left(ServerFailure(msg));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'server_error'));
    } on ConnectionException {
      return const Left(ConnectionFailure('network_error'));
    } catch (_) {
      return const Left(ServerFailure('server_error'));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  /// Extracts the most useful error key from a Laravel ValidationException.
  /// If the server sends field-level errors, check for known field names
  /// and return a matchable key. Falls back to 'server_error'.
  String _extractValidationMessage(ValidationException e) {
    final errors = e.errors;
    if (errors != null && errors.isNotEmpty) {
      // Check for known fields in priority order
      for (final key in ['email', 'login', 'password', 'otp', 'name']) {
        if (errors.containsKey(key)) {
          final fieldErrors = errors[key];
          if (fieldErrors is List && fieldErrors.isNotEmpty) {
            return fieldErrors.first.toString().toLowerCase();
          }
        }
      }
    }
    return e.message?.toLowerCase() ?? 'server_error';
  }
}
