import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class AddressRemoteDataSource {
  Future<List<dynamic>> getAddresses();
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> addressData);
  Future<Map<String, dynamic>> updateAddress(
      String id, Map<String, dynamic> addressData);
  Future<void> deleteAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient apiClient;

  AddressRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getAddresses() async {
    final response = await apiClient.get(ApiEndpoints.addresses);
    if (response.data is Map) {
      final addressesData = response.data['addresses'];
      if (addressesData is Map && addressesData['data'] is List) {
        return addressesData['data'] as List<dynamic>;
      } else if (response.data['data'] is List) {
        return response.data['data'] as List<dynamic>;
      }
    } else if (response.data is List) {
      return response.data as List<dynamic>;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> addAddress(
      Map<String, dynamic> addressData) async {
    final response =
        await apiClient.post(ApiEndpoints.addressStore, data: addressData);
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> updateAddress(
      String id, Map<String, dynamic> addressData) async {
    final response =
        await apiClient.put(ApiEndpoints.addressUpdate(id), data: addressData);
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<void> deleteAddress(String id) async {
    await apiClient.delete(ApiEndpoints.addressDelete(id));
  }
}
