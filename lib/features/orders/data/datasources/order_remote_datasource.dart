import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class OrderRemoteDataSource {
  Future<List<dynamic>> getOrders();
  Future<Map<String, dynamic>> getOrderDetail(String orderNumber);
  Future<void> cancelOrder(String orderId);
  Future<Map<String, dynamic>> submitReview(
      String orderId, String productId, int rating, String comment);
  Future<String> downloadInvoice(String orderNumber);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getOrders() async {
    final response = await apiClient.get(ApiEndpoints.orders);
    final data = response.data;
    if (data is List) {
      return data;
    } else if (data is Map) {
      if (data['orders'] is Map && data['orders']['data'] is List) {
        return data['orders']['data'] as List<dynamic>;
      } else if (data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getOrderDetail(String orderNumber) async {
    final response = await apiClient.get(ApiEndpoints.orderDetail(orderNumber));
    if (response.data is Map<String, dynamic>) {
      if (response.data.containsKey('data')) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return response.data as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await apiClient.post(ApiEndpoints.cancelOrder(orderId));
  }

  @override
  Future<Map<String, dynamic>> submitReview(
      String orderId, String productId, int rating, String comment) async {
    final response = await apiClient.post(
      ApiEndpoints.addReview,
      data: {
        'order_id': orderId,
        'product_id': productId,
        'rating': rating,
        'comment': comment,
      },
    );
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<String> downloadInvoice(String orderNumber) async {
    final response =
        await apiClient.get(ApiEndpoints.orderInvoice(orderNumber));
    if (response.data is Map && response.data['success'] == true) {
      return response.data['url'] as String? ?? '';
    }
    return '';
  }
}
