import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class GetSubCategoryProductsUseCase {
  final ProductRepository repository;

  GetSubCategoryProductsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
      String mainSlug, String subSlug) async {
    return await repository.getCategoryProducts(mainSlug, subSlug);
  }
}
