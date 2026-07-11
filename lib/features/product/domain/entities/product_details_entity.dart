import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product_entity.dart';
import 'review_entity.dart';

class ProductDetailsEntity extends Equatable {
  final ProductEntity baseProduct;
  final List<String> imageGallery;
  final List<int?> imageIds;
  final String description;
  final List<String> availableSizes;
  final List<String> availableColors;
  final Map<int, double>
      ratingDistribution; // e.g., {5: 0.8, 4: 0.15, 3: 0.05, 2: 0, 1: 0}
  final List<ReviewEntity> reviews;
  final List<ProductEntity> similarProducts;
  final String? sku;
  final List<String> tags;

  const ProductDetailsEntity({
    required this.baseProduct,
    required this.imageGallery,
    this.imageIds = const [],
    required this.description,
    required this.availableSizes,
    required this.availableColors,
    required this.ratingDistribution,
    required this.reviews,
    required this.similarProducts,
    this.sku,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
        baseProduct,
        imageGallery,
        imageIds,
        description,
        availableSizes,
        availableColors,
        ratingDistribution,
        reviews,
        similarProducts,
        sku,
        tags,
      ];
}
