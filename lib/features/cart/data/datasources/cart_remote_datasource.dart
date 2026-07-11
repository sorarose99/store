import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class CartRemoteDataSource {
  Future<Map<String, dynamic>> getCart();
  Future<Map<String, dynamic>> addToCart(String productId, int quantity,
      {int? imageId});
  Future<Map<String, dynamic>> updateCart(String productId, int quantity,
      {List<Map<String, dynamic>>? breakdown});
  Future<Map<String, dynamic>> updateBreakdown(
      String productId, List<Map<String, dynamic>> breakdown);
  Future<void> removeFromCart(String productId);
  Future<Map<String, dynamic>> applyCoupon(String code);
  Future<Map<String, dynamic>> removeCoupon();
  Future<Map<String, dynamic>> updateShippingZone(int zoneId);
  Future<int> getCartCount();
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getCart() async {
    final response = await apiClient.get(ApiEndpoints.cart);
    if (response.data is Map<String, dynamic>) {
      return response.data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> addToCart(String productId, int quantity,
      {int? imageId}) async {
    final payload = <String, dynamic>{
      'product_id': int.tryParse(productId) ?? productId,
      'quantity': quantity,
    };
    if (imageId != null) {
      payload['image_id'] = imageId;
    }
    final response = await apiClient.post(ApiEndpoints.cartAdd, data: payload);
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> updateCart(
      String productId, int quantity, {List<Map<String, dynamic>>? breakdown}) async {
    final payload = <String, dynamic>{
      'quantity': quantity,
    };
    if (breakdown != null) {
      payload['breakdown'] = breakdown;
    }
    final response =
        await apiClient.put(ApiEndpoints.cartUpdate(productId), data: payload);
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> updateBreakdown(
      String productId, List<Map<String, dynamic>> breakdown) async {
    final response =
        await apiClient.put(ApiEndpoints.cartBreakdown(productId), data: {
      'breakdown': breakdown,
    });
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<void> removeFromCart(String productId) async {
    await apiClient.delete(ApiEndpoints.cartRemove(productId));
  }

  @override
  Future<Map<String, dynamic>> applyCoupon(String code) async {
    final response = await apiClient.post(ApiEndpoints.cartCoupon, data: {
      'coupon_code': code,
    });
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> removeCoupon() async {
    final response = await apiClient.delete(ApiEndpoints.cartRemoveCoupon);
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> updateShippingZone(int zoneId) async {
    final response = await apiClient.post(ApiEndpoints.cartShippingZone, data: {
      'zone_id': zoneId,
    });
    return response.data as Map<String, dynamic>? ?? {};
  }

  @override
  Future<int> getCartCount() async {
    final response = await apiClient.get(ApiEndpoints.cartCount);
    if (response.data is Map && response.data['count'] != null) {
      return response.data['count'] as int;
    }
    return 0;
  }

  @override
  Future<void> clearCart() async {
    await apiClient.delete(ApiEndpoints.cartClear);
  }
}
