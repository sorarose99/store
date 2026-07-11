import '../../../../core/network/api_client.dart';

abstract class ApiValidationRemoteDataSource {
  Future<void> validateApiKeyFromServer();
}

class ApiValidationRemoteDataSourceImpl
    implements ApiValidationRemoteDataSource {
  final ApiClient apiClient;

  ApiValidationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> validateApiKeyFromServer() async {
    // Calling a lightweight handshake endpoint to verify API Key
    await apiClient.get('/api/v1/validate-key');
  }
}
