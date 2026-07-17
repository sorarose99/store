import '../../domain/entities/product_details_entity.dart';
import '../../../home/data/models/product_model.dart';
import '../../../../core/network/api_endpoints.dart';
import 'review_model.dart';

class ProductDetailsModel extends ProductDetailsEntity {
  const ProductDetailsModel({
    required super.baseProduct,
    required super.imageGallery,
    super.imageIds = const [],
    required super.description,
    required super.availableSizes,
    required super.availableColors,
    required super.ratingDistribution,
    required super.reviews,
    required super.similarProducts,
    super.sku,
    super.tags = const [],
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    // We assume the API returns the base product details in a "product" or "base_product"
    // object, or flattened in the root json.
    final baseProductMap = json['product'] as Map<String, dynamic>? ??
        json['base_product'] as Map<String, dynamic>? ??
        json;
    final baseProduct = ProductModel.fromJson(baseProductMap);

    // Parse image gallery + ids
    List<String> imageGallery = [];
    List<int?> imageIds = [];
    if (baseProductMap['image_gallery'] != null) {
      imageGallery = List<String>.from(baseProductMap['image_gallery'])
          .map((img) => ApiEndpoints.mediaUrl(img))
          .toList();
    } else if (baseProductMap['images'] != null) {
      final imgList = baseProductMap['images'] as List<dynamic>;
      for (var imgObj in imgList) {
        if (imgObj is Map) {
          imageIds.add(int.tryParse(imgObj['id']?.toString() ?? ''));
          String path = imgObj['path']?.toString() ?? '';
          if (path.isNotEmpty) {
            imageGallery.add(ApiEndpoints.mediaUrl(path));
          }
        } else if (imgObj is String) {
          imageIds.add(null);
          String path = imgObj;
          if (path.isNotEmpty) {
            imageGallery.add(ApiEndpoints.mediaUrl(path));
          }
        }
      }
    }

    // Parse sizes
    List<String> availableSizes = [];
    if (baseProductMap['available_sizes'] != null) {
      availableSizes = List<String>.from(baseProductMap['available_sizes']);
    } else if (baseProductMap['sizes'] != null) {
      final sizeList = baseProductMap['sizes'] as List<dynamic>;
      for (var sizeObj in sizeList) {
        if (sizeObj is Map) {
          availableSizes.add(sizeObj['name']?.toString() ?? '');
        } else if (sizeObj is String) {
          availableSizes.add(sizeObj);
        }
      }
    }

    // Parse colors
    List<String> availableColors = [];
    if (baseProductMap['available_colors'] != null) {
      availableColors = List<String>.from(baseProductMap['available_colors']);
    } else if (baseProductMap['colors'] != null) {
      availableColors = List<String>.from(baseProductMap['colors']);
    }

    // Parse rating distribution
    Map<int, double> ratingDistribution = {};
    if (json['rating_distribution'] != null) {
      final Map<String, dynamic> ratingMap = json['rating_distribution'];
      ratingMap.forEach((key, value) {
        ratingDistribution[int.parse(key)] = (value as num).toDouble();
      });
    }

    // Parse reviews
    List<ReviewModel> reviews = [];
    if (baseProductMap['reviews'] != null) {
      reviews = (baseProductMap['reviews'] as List)
          .map((v) => ReviewModel.fromJson(v))
          .toList();
    } else if (json['reviews'] != null) {
      reviews = (json['reviews'] as List)
          .map((v) => ReviewModel.fromJson(v))
          .toList();
    }

    // Parse similar products
    List<ProductModel> similarProducts = [];
    if (json['relatedProducts'] != null) {
      similarProducts = (json['relatedProducts'] as List)
          .map((v) => ProductModel.fromJson(v))
          .toList();
    } else if (json['similar_products'] != null) {
      similarProducts = (json['similar_products'] as List)
          .map((v) => ProductModel.fromJson(v))
          .toList();
    }

    // Parse tags
    List<String> tags = [];
    if (baseProductMap['tags'] != null) {
      final tagList = baseProductMap['tags'] as List<dynamic>;
      for (var tagObj in tagList) {
        if (tagObj is Map) {
          tags.add(tagObj['name']?.toString() ?? '');
        } else if (tagObj is String) {
          tags.add(tagObj);
        }
      }
    }

    return ProductDetailsModel(
      baseProduct: baseProduct,
      imageGallery:
          imageGallery.isNotEmpty ? imageGallery : [baseProduct.imageAsset],
      imageIds: imageIds,
      description: json['product']?['description_ar'] as String? ??
          json['product']?['description_en'] as String? ??
          json['description_ar'] as String? ??
          json['description_en'] as String? ??
          json['description'] as String? ??
          '',
      availableSizes: availableSizes,
      availableColors: availableColors,
      ratingDistribution: ratingDistribution,
      reviews: reviews,
      similarProducts: similarProducts,
      sku: baseProductMap['sku']?.toString(),
      tags: tags,
    );
  }
}
