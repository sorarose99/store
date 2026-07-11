import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/nav_category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/nav_category_model.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/data/models/product_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CategoryData>> getCategories({int page = 1}) async {
    try {
      developer.log('CategoryData received, beginning parsing...',
          name: 'CategoryRepository');
      final data = await remoteDataSource.fetchCategories(page: page);

      final categoryData = data['categories'] is Map
          ? data['categories']['data'] as List<dynamic>? ?? []
          : (data['categories'] as List<dynamic>? ?? []);

      final mainCategories = categoryData
          .map((e) => MainCategoryModel.fromJsonSafe(e as Map<String, dynamic>))
          .whereType<MainCategoryModel>()
          .toList();

      final subCategoriesRaw =
          data['sub_categories'] as Map<String, dynamic>? ?? {};
      final Map<String, List<SubCategoryEntity>> subCategories = {};

      subCategoriesRaw.forEach((key, value) {
        final list = (value as List<dynamic>)
            .map(
                (e) => SubCategoryModel.fromJsonSafe(e as Map<String, dynamic>))
            .whereType<SubCategoryModel>()
            .toList();
        subCategories[key] = list;
      });

      developer.log(
          'Parsed successfully: ${mainCategories.length} main categories',
          name: 'CategoryRepository');

      return Right(CategoryData(
        mainCategories: mainCategories,
        subCategories: subCategories,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubCategoryEntity>>> getSubCategories(
      String slug) async {
    try {
      developer.log('Fetching subcategories for $slug...',
          name: 'CategoryRepository');
      final data = await remoteDataSource.fetchCategoryDetails(slug);

      final subCategoriesData = data['sub_categories'] as List<dynamic>? ?? [];

      final subCategories = subCategoriesData
          .map((e) => SubCategoryModel.fromJsonSafe(e as Map<String, dynamic>))
          .whereType<SubCategoryModel>()
          .toList();

      developer.log(
          'Parsed successfully: ${subCategories.length} subcategories',
          name: 'CategoryRepository');

      return Right(subCategories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getCategoryProducts(
      String categorySlug) async {
    try {
      developer.log(
          'CategoryProducts received for $categorySlug, beginning parsing...',
          name: 'CategoryRepository');
      final data = await remoteDataSource.fetchCategoryProducts(categorySlug);
      final products = data
          .map((e) => ProductModel.fromJsonSafe(e as Map<String, dynamic>))
          .whereType<ProductModel>()
          .toList();
      developer.log('Parsed successfully: ${products.length} products',
          name: 'CategoryRepository');
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
