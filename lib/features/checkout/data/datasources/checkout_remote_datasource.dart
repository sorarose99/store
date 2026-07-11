import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class CheckoutRemoteDataSource {
  Future<List<dynamic>> getAddresses();
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> addressData);
  Future<Map<String, dynamic>> submitCheckout(
      Map<String, dynamic> checkoutData);
  Future<Map<String, dynamic>> getCheckoutData();
  Future<Map<String, dynamic>> editAddress(
      int id, Map<String, dynamic> addressData);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final ApiClient apiClient;

  CheckoutRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getAddresses() async {
    final response = await apiClient.get(ApiEndpoints.addresses);
    final data = response.data;

    if (data is Map) {
      final addressesData = data['addresses'];
      if (addressesData is Map && addressesData['data'] is List) {
        return addressesData['data'] as List<dynamic>;
      }
      if (data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
    } else if (data is List) {
      return data;
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
  Future<Map<String, dynamic>> submitCheckout(
      Map<String, dynamic> checkoutData) async {
    final response =
        await apiClient.post(ApiEndpoints.orders, data: checkoutData);
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> getCheckoutData() async {
    final response = await apiClient.get(ApiEndpoints.cartCheckout);
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> editAddress(
      int id, Map<String, dynamic> addressData) async {
    final response = await apiClient
        .post(ApiEndpoints.addressUpdate(id.toString()), data: addressData);
    return response.data as Map<String, dynamic>? ?? {};
  }
}
