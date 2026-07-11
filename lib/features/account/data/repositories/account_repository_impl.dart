import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/account_entities.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';
import '../models/account_order_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      // First try to get from backend via remote data source
      try {
        final data = await remoteDataSource.getProfile();
        // Assume API returns a user object inside a "data" or "user" key, or directly
        final userData = data['user'] ?? data['data'] ?? data;
        if (userData.isNotEmpty) {
          return Right(UserModel(
            name: userData['name'] ?? 'User',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            walletBalance: (userData['wallet_balance'] as num?)?.toDouble() ?? 0.0,
            ordersCount: userData['orders_count'] ?? 0,
            gender: userData['gender'] ?? '',
            dateOfBirth: DateTime.tryParse(userData['date_of_birth']?.toString() ?? '') ?? DateTime.now(),
          ));
        }
      } catch (e) {
        // If API fails, fallback to Firebase if available
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          return Right(UserModel(
            name: currentUser.displayName ?? 'User',
            email: currentUser.email ?? '',
            phone: currentUser.phoneNumber ?? '',
            walletBalance: 0.0,
            ordersCount: 0,
            gender: '',
            dateOfBirth: DateTime.now(),
          ));
        }
        rethrow;
      }
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(ServerFailure('User not logged in'));
      }
      return Right(UserModel(
        name: currentUser.displayName ?? 'User',
        email: currentUser.email ?? '',
        phone: currentUser.phoneNumber ?? '',
        walletBalance: 0.0,
        ordersCount: 0,
        gender: '',
        dateOfBirth: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      developer.log('getProfile error', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<
          Either<Failure,
              ({DashboardStatsEntity stats, List<OrderEntity> recentOrders})>>
      getDashboardData() async {
    try {
      final data = await remoteDataSource.getDashboardData();
      final stats = DashboardStatsModel.fromJson(data);

      final List<OrderEntity> recentOrders = [];
      if (data['orders'] != null && data['orders'] is List) {
        for (var item in data['orders']) {
          recentOrders.add(AccountOrderModel.fromJson(item));
        }
      }

      return Right((stats: stats, recentOrders: recentOrders));
    } catch (e, stackTrace) {
      developer.log('getDashboardData error', error: e, stackTrace: stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateProfile(data);
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && data.containsKey('name')) {
        await currentUser.updateDisplayName(data['name']);
        await currentUser.reload();
      }

      // Re-fetch profile to get updated state
      return getProfile();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(newPassword);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String password) async {
    try {
      await remoteDataSource.deleteAccount(password);
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveFcmToken({
    required String token,
    required String deviceId,
    String? platform,
    String? deviceName,
  }) async {
    try {
      await remoteDataSource.saveFcmToken(
        token: token,
        deviceId: deviceId,
        platform: platform,
        deviceName: deviceName,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
