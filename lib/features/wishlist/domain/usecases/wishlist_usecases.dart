import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase {
  final WishlistRepository repository;

  GetWishlistUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call() async {
    return repository.getWishlist();
  }
}

class ToggleWishlistUseCase {
  final WishlistRepository repository;

  ToggleWishlistUseCase(this.repository);

  Future<Either<Failure, bool>> call(String productId) async {
    return repository.toggleWishlist(productId);
  }
}
