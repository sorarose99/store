import 'banner_entity.dart';
import 'brand_entity.dart';
import 'category_entity.dart';
import 'product_entity.dart';
import 'package:equatable/equatable.dart';

class HomeDataEntity extends Equatable {
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final List<BrandEntity> brands;
  final List<ProductEntity> flashSaleProducts;
  final List<ProductEntity> trendingProducts;
  final DateTime? flashSaleEndDate;

  const HomeDataEntity({
    required this.banners,
    required this.categories,
    required this.products,
    required this.brands,
    required this.flashSaleProducts,
    required this.trendingProducts,
    this.flashSaleEndDate,
  });

  @override
  List<Object?> get props => [
        banners,
        categories,
        products,
        brands,
        flashSaleProducts,
        trendingProducts,
        flashSaleEndDate,
      ];
}
