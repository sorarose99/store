import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/checkout_entities.dart';
import '../repositories/checkout_repository.dart';

class GetAddressesUseCase {
  final CheckoutRepository repository;

  GetAddressesUseCase(this.repository);

  Future<Either<Failure, List<SavedAddressEntity>>> call() async {
    return await repository.getAddresses();
  }
}

class AddAddressUseCase {
  final CheckoutRepository repository;

  AddAddressUseCase(this.repository);

  Future<Either<Failure, SavedAddressEntity>> call(
      SavedAddressEntity address) async {
    return await repository.addAddress(address);
  }
}

class SubmitCheckoutUseCase {
  final CheckoutRepository repository;

  SubmitCheckoutUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> checkoutData) async {
    return await repository.submitCheckout(checkoutData);
  }
}

class GetCheckoutDataUseCase {
  final CheckoutRepository repository;

  GetCheckoutDataUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getCheckoutData();
  }
}

class EditAddressUseCase {
  final CheckoutRepository repository;

  EditAddressUseCase(this.repository);

  Future<Either<Failure, SavedAddressEntity>> call(
      int id, SavedAddressEntity address) async {
    return await repository.editAddress(id, address);
  }
}
