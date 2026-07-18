import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> sendRegisterOtp({required String email});

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String otpCode,
  });

  Future<void> sendForgotOtp({required String email});

  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String passwordConfirmation,
  });

  Future<void> logout();

  Future<String> socialLogin({
    required String provider,
    required String token,
    required String name,
    required String email,
    String? firebaseUid,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  // ── Login ─────────────────────────────────────────────────────────
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {
        'login': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return UserModel.fromJson(response.data);
    }
    throw ServerException(
        message: response.data['message'] ?? 'Login failed');
  }

  // ── Register: Step 1 — Send OTP ───────────────────────────────────
  @override
  Future<void> sendRegisterOtp({required String email}) async {
    final response = await apiClient.post(
      ApiEndpoints.sendRegisterOtp,
      data: {
        'register_type': 'email',
        'email': email,
      },
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException(
          message: response.data['message'] ?? 'Failed to send OTP');
    }
  }

  // ── Register: Step 2 — Create Account ────────────────────────────
  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String otpCode,
  }) async {
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
    final lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(' ')
        : 'User';

    final response = await apiClient.post(
      ApiEndpoints.register,
      data: {
        'register_type': 'email',
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'otp': otpCode,
        'terms': true,
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return UserModel.fromJson(response.data);
    }
    throw ServerException(
        message: response.data['message'] ?? 'Registration failed');
  }

  // ── Forgot Password: Step 1 — Send OTP ───────────────────────────
  @override
  Future<void> sendForgotOtp({required String email}) async {
    final response = await apiClient.post(
      ApiEndpoints.sendForgotOtp,
      data: {
        'target': email,
      },
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException(
          message: response.data['message'] ?? 'Failed to send OTP');
    }
  }

  // ── Forgot Password: Step 2 — Reset ──────────────────────────────
  @override
  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'target': email,
        'otp': otpCode,
        'password': newPassword,
        'password_confirmation': passwordConfirmation,
      },
    );

    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException(
          message: response.data['message'] ?? 'Password reset failed');
    }
  }

  // ── Logout ────────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore errors on logout
    }
  }

  // ── Social Login ─────────────────────────────────────────────
  @override
  Future<String> socialLogin({
    required String provider,
    required String token,
    required String name,
    required String email,
    String? firebaseUid,
  }) async {
    try {
      final dio = Dio();
      dio.options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      final String uid = firebaseUid ?? token;
      
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.socialLogin}',
        data: {
          'email': email,
          'name': name,
          'firebase_uid': uid,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['token'] as String;
      }
      throw ServerException(
          message: response.data['message'] ?? 'Failed to sync with backend');
    } on DioException catch (e) {
      developer.log(
          'Social Login Dio Error: ${e.response?.statusCode} - ${e.response?.data}',
          name: 'Auth');
      throw ServerException(message: 'Sync failed: ${e.message}');
    } catch (e) {
      developer.log('Social Login Error: $e', name: 'Auth');
      throw ServerException(message: 'Sync failed: $e');
    }
  }
}
