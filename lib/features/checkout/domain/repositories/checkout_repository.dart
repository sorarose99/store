import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/checkout_entities.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, List<SavedAddressEntity>>> getAddresses();
  Future<Either<Failure, SavedAddressEntity>> addAddress(
      SavedAddressEntity address);
  Future<Either<Failure, Map<String, dynamic>>> submitCheckout(
      Map<String, dynamic> checkoutData);
  Future<Either<Failure, Map<String, dynamic>>> getCheckoutData();
  Future<Either<Failure, SavedAddressEntity>> editAddress(
      int id, SavedAddressEntity address);
}
