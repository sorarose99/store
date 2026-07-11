import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../checkout/domain/entities/checkout_entities.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<SavedAddressEntity>>> getAddresses();
  Future<Either<Failure, SavedAddressEntity>> addAddress(
      SavedAddressEntity address);
  Future<Either<Failure, SavedAddressEntity>> updateAddress(
      String id, SavedAddressEntity address);
  Future<Either<Failure, void>> deleteAddress(String id);
}
