import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double? originalPrice;
  final String imageAsset; // asset path or network URL key
  final bool isNew;
  final bool isSale;
  final bool isFreeDelivery;
  final double rating;
  final int reviewCount;
  final bool isWishlisted;
  final String? discountLabel; // e.g. "اليوم", "بكرة"
  final String categoryId;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.originalPrice,
    required this.imageAsset,
    this.isNew = false,
    this.isSale = false,
    this.isFreeDelivery = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isWishlisted = false,
    this.discountLabel,
    required this.categoryId,
  });

  int? get discountPercent {
    if (originalPrice == null || originalPrice == 0) return null;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        price,
        originalPrice,
        imageAsset,
        isNew,
        isSale,
        isFreeDelivery,
        rating,
        reviewCount,
        isWishlisted,
        discountLabel,
        categoryId,
      ];
}
