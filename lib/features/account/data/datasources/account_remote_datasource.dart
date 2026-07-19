import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class AccountRemoteDataSource {
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> getDashboardData();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount(String password);
  Future<void> saveFcmToken({
    required String token,
    required String deviceId,
    String? platform,
    String? deviceName,
  });
  Future<void> sendContactMessage(Map<String, dynamic> data);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiClient apiClient;

  AccountRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await apiClient.get(ApiEndpoints.profile);
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await apiClient.get(ApiEndpoints.myAccount);
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    dynamic payload = data;

    // Convert to FormData if there is a local file in 'avatar'
    if (data.containsKey('avatar') &&
        data['avatar'] != null &&
        !data['avatar'].toString().startsWith('http')) {
      final formDataMap = <String, dynamic>{};

      data.forEach((key, value) {
        if (key != 'avatar') {
          formDataMap[key] = value;
        }
      });

      final formData = FormData.fromMap(formDataMap);
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(data['avatar']),
      ));

      payload = formData;
    }

    Response response;
    if (payload is FormData) {
      payload.fields.add(const MapEntry('_method', 'PUT'));
      response = await apiClient.post(ApiEndpoints.profile, data: payload);
    } else {
      response = await apiClient.put(ApiEndpoints.profile, data: payload);
    }
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await apiClient.put(ApiEndpoints.changePassword, data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPassword,
    });
  }

  @override
  Future<void> deleteAccount(String password) async {
    final data = <String, dynamic>{};
    if (password.isNotEmpty) {
      data['password'] = password;
    }
    await apiClient.delete(ApiEndpoints.deleteAccount, data: data);
  }

  @override
  Future<void> saveFcmToken({
    required String token,
    required String deviceId,
    String? platform,
    String? deviceName,
  }) async {
    await apiClient.post(ApiEndpoints.saveFcmToken, data: {
      'token': token,
      'device_id': deviceId,
      'platform': platform ?? 'android',
      'device_name': deviceName ?? 'device',
    });
  }

  @override
  Future<void> sendContactMessage(Map<String, dynamic> data) async {
    await apiClient.post(ApiEndpoints.contactUs, data: data);
  }
}
