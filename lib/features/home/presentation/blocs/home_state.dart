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
  final List<ProductEntity> products; // currently displayed
  final List<ProductEntity> allProducts; // cached for filtering
  final List<BrandEntity> brands;
  final List<ProductEntity> flashSaleProducts;
  final List<ProductEntity> trendingProducts;
  final DateTime? flashSaleEndDate;
  final String selectedCategoryId;

  const HomeLoaded({
    required this.banners,
    required this.categories,
    required this.products,
    required this.allProducts,
    required this.brands,
    required this.flashSaleProducts,
    required this.trendingProducts,
    this.flashSaleEndDate,
    this.selectedCategoryId = 'cat_all',
  });

  HomeLoaded copyWith({
    List<BannerEntity>? banners,
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    List<ProductEntity>? allProducts,
    List<BrandEntity>? brands,
    List<ProductEntity>? flashSaleProducts,
    List<ProductEntity>? trendingProducts,
    DateTime? flashSaleEndDate,
    String? selectedCategoryId,
  }) {
    return HomeLoaded(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      brands: brands ?? this.brands,
      flashSaleProducts: flashSaleProducts ?? this.flashSaleProducts,
      trendingProducts: trendingProducts ?? this.trendingProducts,
      flashSaleEndDate: flashSaleEndDate ?? this.flashSaleEndDate,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [
        banners,
        categories,
        products,
        allProducts,
        brands,
        flashSaleProducts,
        trendingProducts,
        flashSaleEndDate,
        selectedCategoryId,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
