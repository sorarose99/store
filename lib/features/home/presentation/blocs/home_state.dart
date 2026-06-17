import 'package:equatable/equatable.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final List<BrandEntity> brands;
  final List<ProductEntity> flashSaleProducts;
  final List<ProductEntity> trendingProducts;
  final String selectedCategoryId;

  const HomeLoaded({
    required this.banners,
    required this.categories,
    required this.products,
    required this.brands,
    required this.flashSaleProducts,
    required this.trendingProducts,
    this.selectedCategoryId = 'cat_all',
  });

  HomeLoaded copyWith({
    List<BannerEntity>? banners,
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    List<BrandEntity>? brands,
    List<ProductEntity>? flashSaleProducts,
    List<ProductEntity>? trendingProducts,
    String? selectedCategoryId,
  }) {
    return HomeLoaded(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      brands: brands ?? this.brands,
      flashSaleProducts: flashSaleProducts ?? this.flashSaleProducts,
      trendingProducts: trendingProducts ?? this.trendingProducts,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [
        banners,
        categories,
        products,
        brands,
        flashSaleProducts,
        trendingProducts,
        selectedCategoryId,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
