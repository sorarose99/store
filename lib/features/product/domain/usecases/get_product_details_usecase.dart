import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_details_entity.dart';
import '../repositories/product_repository.dart';

class GetProductDetailsUseCase {
  final ProductRepository repository;

  GetProductDetailsUseCase(this.repository);

  Future<Either<Failure, ProductDetailsEntity>> call(String slug) async {
    return await repository.getProductDetails(slug);
  }
}
