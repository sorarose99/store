import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoryProductsUseCase {
  final CategoryRepository repository;

  GetCategoryProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call(String categorySlug) async {
    return await repository.getCategoryProducts(categorySlug);
  }
}
