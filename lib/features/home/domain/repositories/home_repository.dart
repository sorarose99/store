import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/banner_entity.dart';
import '../entities/brand_entity.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

/// Abstract contract – swap the impl with a real API repo later.
abstract class HomeRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners();
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<ProductEntity>>> getProducts({String? categoryId});
  Future<Either<Failure, List<BrandEntity>>> getBrands();
  Future<Either<Failure, List<ProductEntity>>> getFlashSaleProducts();
  Future<Either<Failure, List<ProductEntity>>> getTrendingProducts();
}
