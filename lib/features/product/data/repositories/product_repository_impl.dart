import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product_details_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProductDetailsEntity>> getProductDetails(
      String slug) async {
    try {
      final productDetails = await remoteDataSource.getProductDetails(slug);
      return Right(productDetails);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'error_server'));
    } catch (e, stack) {
      print('ProductRepositoryImpl getProductDetails error: $e');
      print(stack);
      return const Left(ServerFailure('error_unexpected'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getShopProducts(
      Map<String, dynamic> filters) async {
    try {
      final result = await remoteDataSource.getShopProducts(filters);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'error_server'));
    } catch (e) {
      return const Left(ServerFailure('error_unexpected'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCategoryProducts(
      String mainSlug, String subSlug) async {
    try {
      final result =
          await remoteDataSource.getCategoryProducts(mainSlug, subSlug);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'error_server'));
    } catch (e) {
      return const Left(ServerFailure('error_unexpected'));
    }
  }
}
