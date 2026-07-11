import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/product_details_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductDetailsModel> getProductDetails(String slug);
  Future<Map<String, dynamic>> getShopProducts(Map<String, dynamic> filters);
  Future<Map<String, dynamic>> getCategoryProducts(
      String mainSlug, String subSlug);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  Future<String> _resolveSlugIfNumeric(String slug) async {
    // If it is NOT a numeric ID AND does NOT contain spaces, it's likely a valid slug.
    if (int.tryParse(slug) == null && !slug.contains(' ')) {
      return slug;
    }
    try {
      final response = await apiClient.get('/shop', queryParameters: {'search': slug});
      if (response.data != null && response.data['success'] == true) {
        final productsData = response.data['products'];
        if (productsData != null && productsData['data'] != null) {
          final list = productsData['data'] as List<dynamic>;
          for (var item in list) {
            if (item['id']?.toString() == slug ||
                item['name_ar'] == slug ||
                item['name_en'] == slug ||
                item['name'] == slug) {
              final foundSlug = item['slug']?.toString();
              if (foundSlug != null && foundSlug.isNotEmpty) {
                debugPrint('[ProductRemoteDataSource] Resolved "$slug" to slug $foundSlug');
                return foundSlug;
              }
            }
          }
          // Fallback: if search returned results, use the first result's slug
          if (list.isNotEmpty) {
            final firstSlug = list.first['slug']?.toString();
            if (firstSlug != null && firstSlug.isNotEmpty) {
              debugPrint('[ProductRemoteDataSource] Fallback resolved "$slug" to first result slug $firstSlug');
              return firstSlug;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[ProductRemoteDataSource] Error resolving slug: $e');
    }
    return slug;
  }

  @override
  Future<ProductDetailsModel> getProductDetails(String slug) async {
    final resolvedSlug = await _resolveSlugIfNumeric(slug);
    final futures = await Future.wait([
      apiClient.get(ApiEndpoints.product(resolvedSlug)),
      apiClient.get(ApiEndpoints.productReviews(resolvedSlug)),
    ]);

    final productResponse = futures[0];
    final reviewsResponse = futures[1];

    // Assumes response.data contains 'data' wrapper as typical in Laravel/REST APIs
    // e.g. { "data": { ...product info... } }
    // If not wrapped, use response.data directly.
    final data = productResponse.data['data'] ?? productResponse.data;

    // Attempt to merge reviews into data
    if (data is Map<String, dynamic>) {
      final reviewsData = reviewsResponse.data['data'] ?? reviewsResponse.data;
      if (reviewsData is List) {
        data['reviews'] = reviewsData;
      }
    }

    return ProductDetailsModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> getShopProducts(
      Map<String, dynamic> filters) async {
    final response =
        await apiClient.get(ApiEndpoints.shop, queryParameters: filters);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> getCategoryProducts(
      String mainSlug, String subSlug) async {
    final response =
        await apiClient.get(ApiEndpoints.categoryProducts(mainSlug, subSlug));
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }
}
