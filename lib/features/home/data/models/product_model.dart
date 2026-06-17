import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
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
  });

  /// Factory from API JSON — ready for real integration
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      imageAsset: json['image_asset'] as String,
      isNew: json['is_new'] as bool? ?? false,
      isSale: json['is_sale'] as bool? ?? false,
      isFreeDelivery: json['is_free_delivery'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isWishlisted: json['is_wishlisted'] as bool? ?? false,
      discountLabel: json['discount_label'] as String?,
      categoryId: json['category_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}
