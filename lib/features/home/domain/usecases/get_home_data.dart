import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/banner_entity.dart';
import '../entities/brand_entity.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeData {
  final HomeRepository repository;

  GetHomeData(this.repository);

  Future<Either<Failure, HomeData>> call() async {
    final bannersResult = await repository.getBanners();
    final categoriesResult = await repository.getCategories();
    final productsResult = await repository.getProducts();
    final brandsResult = await repository.getBrands();
    final flashSaleResult = await repository.getFlashSaleProducts();
    final trendingResult = await repository.getTrendingProducts();

    // Fail fast if any request fails
    if (bannersResult.isLeft()) {
      return Left(bannersResult.fold((l) => l, (_) => ServerFailure('خطأ في السيرفر')));
    }
    if (categoriesResult.isLeft()) {
      return Left(categoriesResult.fold((l) => l, (_) => ServerFailure('خطأ في السيرفر')));
    }
    if (productsResult.isLeft()) {
      return Left(productsResult.fold((l) => l, (_) => ServerFailure('خطأ في السيرفر')));
    }

    return Right(HomeData(
      banners: bannersResult.getOrElse(() => []),
      categories: categoriesResult.getOrElse(() => []),
      products: productsResult.getOrElse(() => []),
      brands: brandsResult.getOrElse(() => []),
      flashSaleProducts: flashSaleResult.getOrElse(() => []),
      trendingProducts: trendingResult.getOrElse(() => []),
    ));
  }
}

class HomeData {
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;
  final List<BrandEntity> brands;
  final List<ProductEntity> flashSaleProducts;
  final List<ProductEntity> trendingProducts;

  const HomeData({
    required this.banners,
    required this.categories,
    required this.products,
    required this.brands,
    required this.flashSaleProducts,
    required this.trendingProducts,
  });
}
