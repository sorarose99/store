import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<void> forgotPassword({
    required String phoneNumber,
  });

  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  });

  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  
  // Set this to false to link directly with your backend REST API endpoints
  static const bool useMockData = true;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login({
    required String phoneNumber,
    required String password,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1200));
      return UserModel(
        id: '12345',
        name: 'كريم أحمد',
        email: 'krem@github.com',
        phoneNumber: phoneNumber,
        token: 'mock_jwt_token_xyz123',
      );
    }

    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {
        'phone_number': phoneNumber,
        'password': password,
      },
    );

    if (response.data != null) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('فشل تسجيل الدخول. استجابة فارغة من الخادم.');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1200));
      return UserModel(
        id: '12345',
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        token: 'mock_jwt_token_xyz123',
      );
    }

    final response = await apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
      },
    );

    if (response.data != null) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('فشل إنشاء الحساب. استجابة فارغة من الخادم.');
    }
  }

  @override
  Future<void> forgotPassword({
    required String phoneNumber,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }

    await apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {
        'phone_number': phoneNumber,
      },
    );
  }

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      // Hardcode acceptance for verification code
      return UserModel(
        id: '12345',
        name: 'كريم أحمد',
        email: 'krem@github.com',
        phoneNumber: phoneNumber,
        token: 'mock_jwt_token_xyz123',
      );
    }

    final response = await apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
      },
    );

    if (response.data != null) {
      return UserModel.fromJson(response.data);
    } else {
      throw Exception('فشل التحقق من الرمز.');
    }
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return;
    }

    await apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'phone_number': phoneNumber,
        'password': newPassword,
      },
    );
  }
}
