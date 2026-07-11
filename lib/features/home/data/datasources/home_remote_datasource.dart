import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> fetchHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> fetchHomeData() async {
    final response = await apiClient.get(ApiEndpoints.home);
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    } else {
      return {}; // Fallback
    }
  }
}
