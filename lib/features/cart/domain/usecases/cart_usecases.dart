import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_summary_entity.dart';
import '../repositories/cart_repository.dart';
export 'update_breakdown_usecase.dart';
export 'get_cart_count_usecase.dart';
export 'clear_cart_usecase.dart';

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<Either<Failure, CartSummaryEntity>> call() async {
    return await repository.getCart();
  }
}

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId, int quantity,
      {int? imageId, Map<String, dynamic>? options}) async {
    return repository.addToCart(productId, quantity, imageId: imageId, options: options);
  }
}

class UpdateCartUseCase {
  final CartRepository repository;

  UpdateCartUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId, int quantity,
      {List<Map<String, dynamic>>? breakdown}) async {
    return await repository.updateCart(productId, quantity,
        breakdown: breakdown);
  }
}

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId) async {
    return await repository.removeFromCart(productId);
  }
}

class ApplyCouponUseCase {
  final CartRepository repository;

  ApplyCouponUseCase(this.repository);

  Future<Either<Failure, double>> call(String code) async {
    return await repository.applyCoupon(code);
  }
}

class RemoveCouponUseCase {
  final CartRepository repository;

  RemoveCouponUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.removeCoupon();
  }
}

class UpdateShippingZoneUseCase {
  final CartRepository repository;

  UpdateShippingZoneUseCase(this.repository);

  Future<Either<Failure, void>> call(int zoneId) async {
    return await repository.updateShippingZone(zoneId);
  }
}
