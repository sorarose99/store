import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class WishlistRemoteDataSource {
  Future<List<dynamic>> getWishlist();
  Future<Map<String, dynamic>> toggleWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final ApiClient apiClient;

  WishlistRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> getWishlist() async {
    final response = await apiClient.get(ApiEndpoints.wishlist);
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final wishlists = data['wishlists'];
      if (wishlists is Map && wishlists['data'] is List) {
        return wishlists['data'] as List<dynamic>;
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
  Future<Map<String, dynamic>> toggleWishlist(String productId) async {
    final parsedId = int.tryParse(productId);
    final response = await apiClient.post(ApiEndpoints.wishlistToggle, data: {
      'product_id': parsedId ?? productId,
    });
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }
}
