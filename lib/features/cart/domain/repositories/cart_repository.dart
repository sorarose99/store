import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_summary_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartSummaryEntity>> getCart();
  Future<Either<Failure, void>> addToCart(String productId, int quantity,
      {int? imageId});
  Future<Either<Failure, void>> updateCart(String productId, int quantity,
      {List<Map<String, dynamic>>? breakdown});
  Future<Either<Failure, void>> updateBreakdown(
      String productId, List<Map<String, dynamic>> breakdown);
  Future<Either<Failure, void>> removeFromCart(String productId);
  Future<Either<Failure, double>> applyCoupon(String code);
  Future<Either<Failure, void>> removeCoupon();
  Future<Either<Failure, void>> updateShippingZone(int zoneId);
  Future<Either<Failure, int>> getCartCount();
  Future<Either<Failure, void>> clearCart();
}
