import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/nav_category_entity.dart';
import '../../../home/domain/entities/product_entity.dart';

class CategoryData {
  final List<MainCategoryEntity> mainCategories;
  final Map<String, List<SubCategoryEntity>> subCategories;

  CategoryData({required this.mainCategories, required this.subCategories});
}

abstract class CategoryRepository {
  Future<Either<Failure, CategoryData>> getCategories({int page = 1});
  Future<Either<Failure, List<SubCategoryEntity>>> getSubCategories(
      String slug);
  Future<Either<Failure, List<ProductEntity>>> getCategoryProducts(
      String categorySlug);
}
