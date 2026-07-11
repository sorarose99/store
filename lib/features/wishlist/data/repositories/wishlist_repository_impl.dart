import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getWishlist() async {
    try {
      final data = await remoteDataSource.getWishlist();
      final products = <ProductEntity>[];

      for (final entry in data) {
        if (entry is! Map<String, dynamic>) continue;
        final productJson = entry['product'] as Map<String, dynamic>? ?? entry;
        final product = ProductModel.fromJsonSafe(productJson);
        if (product != null) {
          products.add(product);
        }
      }

      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist(String productId) async {
    try {
      final response = await remoteDataSource.toggleWishlist(productId);
      final status = response['status']?.toString();
      if (status == 'added') return const Right(true);
      if (status == 'removed') return const Right(false);
      return Left(ServerFailure(
          response['message']?.toString() ?? 'Wishlist toggle failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
