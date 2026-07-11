import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class CategoryRemoteDataSource {
  Future<Map<String, dynamic>> fetchCategories({int page = 1});
  Future<Map<String, dynamic>> fetchCategoryDetails(String slug);
  Future<List<dynamic>> fetchCategoryProducts(String categorySlug);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> fetchCategories({int page = 1}) async {
    final response = await apiClient.get(
      ApiEndpoints.categories,
      queryParameters: {'page': page},
    );
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> fetchCategoryDetails(String slug) async {
    final response = await apiClient.get(ApiEndpoints.categoryDetails(slug));
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<List<dynamic>> fetchCategoryProducts(String categorySlug) async {
    final response = await apiClient.get(ApiEndpoints.category(categorySlug));

    if (response.data is Map && response.data['products'] != null) {
      final productsData = response.data['products'];
      if (productsData is Map && productsData['data'] is List) {
        return productsData['data'] as List<dynamic>;
      } else if (productsData is List) {
        return productsData;
      }
    }
    return [];
  }
}
