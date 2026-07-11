import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

class GetShopProductsUseCase {
  final ProductRepository repository;

  GetShopProductsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> filters) async {
    return await repository.getShopProducts(filters);
  }
}
