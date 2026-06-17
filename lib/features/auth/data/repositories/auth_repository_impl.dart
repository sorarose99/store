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

  @override
  Future<Either<Failure, User>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      
      if (userModel.token != null) {
        await localDataSource.cacheToken(userModel.token!);
      }
      
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'فشل تسجيل الدخول. يرجى المحاولة لاحقاً.'));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message ?? 'لا يوجد اتصال بالإنترنت.'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      
      if (userModel.token != null) {
        await localDataSource.cacheToken(userModel.token!);
      }
      
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'فشل إنشاء الحساب. يرجى المحاولة لاحقاً.'));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message ?? 'لا يوجد اتصال بالإنترنت.'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({
    required String phoneNumber,
  }) async {
    try {
      await remoteDataSource.forgotPassword(phoneNumber: phoneNumber);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'فشل إرسال رمز التحقق.'));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message ?? 'لا يوجد اتصال بالإنترنت.'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final userModel = await remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
      );
      
      if (userModel.token != null) {
        await localDataSource.cacheToken(userModel.token!);
      }
      
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'رمز التحقق غير صحيح.'));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message ?? 'لا يوجد اتصال بالإنترنت.'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        phoneNumber: phoneNumber,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'فشل إعادة تعيين كلمة المرور.'));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message ?? 'لا يوجد اتصال بالإنترنت.'));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }
}
