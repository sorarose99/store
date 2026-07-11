import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/nav_category_entity.dart';
import '../repositories/category_repository.dart';

class GetSubCategoriesUseCase {
  final CategoryRepository repository;

  GetSubCategoriesUseCase(this.repository);

  Future<Either<Failure, List<SubCategoryEntity>>> call(String slug) async {
    return await repository.getSubCategories(slug);
  }
}
