import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDatasource localDatasource;

  HomeRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      // TODO: replace with remote datasource call when API is ready
      final banners = localDatasource.getBanners();
      return Right(banners as List<BannerEntity>);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = localDatasource.getCategories();
      return Right(categories as List<CategoryEntity>);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? categoryId,
  }) async {
    try {
      final products = localDatasource.getProducts(categoryId: categoryId);
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BrandEntity>>> getBrands() async {
    try {
      final brands = localDatasource.getBrands();
      return Right(brands as List<BrandEntity>);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFlashSaleProducts() async {
    try {
      final products = localDatasource.getFlashSaleProducts();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getTrendingProducts() async {
    try {
      final products = localDatasource.getTrendingProducts();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
