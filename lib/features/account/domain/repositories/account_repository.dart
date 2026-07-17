import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/account_entities.dart';

abstract class AccountRepository {
  Future<Either<Failure, UserEntity>> getProfile();
  Future<
          Either<Failure,
              ({DashboardStatsEntity stats, List<OrderEntity> recentOrders})>>
      getDashboardData();
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, void>> changePassword(
      String currentPassword, String newPassword);
  Future<Either<Failure, void>> deleteAccount(String password);
  Future<Either<Failure, void>> saveFcmToken({
    required String token,
    required String deviceId,
    String? platform,
    String? deviceName,
  });
  Future<Either<Failure, void>> sendContactMessage(Map<String, dynamic> data);
}
