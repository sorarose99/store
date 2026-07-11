import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_details_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductDetailsEntity>> getProductDetails(String slug);
  Future<Either<Failure, Map<String, dynamic>>> getShopProducts(
      Map<String, dynamic> filters);
  Future<Either<Failure, Map<String, dynamic>>> getCategoryProducts(
      String mainSlug, String subSlug);
}
