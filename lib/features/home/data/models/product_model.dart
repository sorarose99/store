import 'dart:developer' as developer;
import '../../domain/entities/product_entity.dart';

import '../../../../core/network/api_endpoints.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.brand,
    required super.price,
    super.originalPrice,
    required super.imageAsset,
    super.isNew,
    super.isSale,
    super.isFreeDelivery,
    super.rating,
    super.reviewCount,
    super.isWishlisted,
    super.discountLabel,
    required super.categoryId,
    super.featured,
    super.requiresShipping,
    super.deliveryNote,
  });

  static ProductModel? fromJsonSafe(Map<String, dynamic> json) {
    try {
      return ProductModel.fromJson(json);
    } catch (e, stackTrace) {
      developer.log('Failed to parse ProductModel for ID: ${json["id"]}',
          error: e, stackTrace: stackTrace, name: 'ProductModel');
      return null;
    }
  }

  /// Factory from API JSON — ready for real integration
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final name = json['name_ar'] as String? ??
        json['name_en'] as String? ??
        json['name'] as String? ??
        '';

    final images = json['images'] as List<dynamic>?;
    String img = '';
    if (images != null && images.isNotEmpty) {
      final primary = images.firstWhere(
        (e) => e is Map && (e['is_primary'] == 1 || e['is_primary'] == true),
        orElse: () => images.isNotEmpty ? images.first : null,
      );
      if (primary is Map) {
        img = primary['path']?.toString() ?? '';
      }
    } else if (json['primary_image'] != null && json['primary_image'] is Map) {
      img = json['primary_image']['path']?.toString() ?? '';
    } else if (json['primaryImage'] != null && json['primaryImage'] is Map) {
      img = json['primaryImage']['path']?.toString() ?? '';
    } else if (json['image'] != null && json['image'] is String) {
      img = json['image'].toString();
    } else {
      img = json['image_asset']?.toString() ?? '';
    }

    if (img.isNotEmpty) {
      img = ApiEndpoints.mediaUrl(img);
    } else {
      img = 'assets/images/fallback_product_1782341998334.png';
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final salePrice = parseDouble(json['sale_price']);
    final originalPrice = parseDouble(json['price']);
    final activePrice = salePrice ?? originalPrice ?? 0.0;

    // Parse rating and review count from backend conventions
    final ratingVal = parseDouble(json['reviews_avg_rating']) ??
        parseDouble(json['rating']) ??
        0.0;

    int parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final reviewCountVal = parseCount(json['reviews_count']) != 0
        ? parseCount(json['reviews_count'])
        : parseCount(json['review_count']);

    bool parseBool(dynamic value) {
      return value == 1 || value == true || value == 1 || value == 'true';
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug'] as String? ?? json['id']?.toString() ?? '',
      name: name,
      brand: json['brand'] != null && json['brand'] is Map
          ? (json['brand']['name'] ?? '')
          : (json['brand'] as String? ?? ''),
      price: activePrice,
      originalPrice: salePrice != null ? originalPrice : null,
      imageAsset: img,
      isNew: parseBool(json['new']) || parseBool(json['is_new']),
      isSale: salePrice != null,
      isFreeDelivery: parseBool(json['is_free_delivery']) ||
          parseBool(json['free_shipping']) ||
          (!parseBool(json['requires_shipping']) &&
              json['requires_shipping'] != null),
      rating: ratingVal,
      reviewCount: reviewCountVal,
      isWishlisted: parseBool(json['is_wishlisted']),
      discountLabel: json['discount_label'] as String?,
      categoryId: json['category_id']?.toString() ?? '',
      featured: parseBool(json['featured']),
      requiresShipping: parseBool(json['requires_shipping']),
      deliveryNote: json['delivery_note'] as String? ??
          (parseBool(json['is_fast_delivery']) || parseBool(json['fast_shipping'])
              ? 'fast'
              : parseBool(json['is_free_delivery']) || parseBool(json['free_shipping'])
                  ? 'free'
                  : 'normal'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'brand': brand,
      'price': price,
      'original_price': originalPrice,
      'image_asset': imageAsset,
      'is_new': isNew,
      'is_sale': isSale,
      'is_free_delivery': isFreeDelivery,
      'rating': rating,
      'review_count': reviewCount,
      'is_wishlisted': isWishlisted,
      'discount_label': discountLabel,
      'category_id': categoryId,
      'featured': featured,
      'requires_shipping': requiresShipping,
      'delivery_note': deliveryNote,
    };
  }
}
