import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/product_entity.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<ProductEntity>>> getWishlist();

  /// Returns true when the item was added, false when removed.
  Future<Either<Failure, bool>> toggleWishlist(String productId);
}
