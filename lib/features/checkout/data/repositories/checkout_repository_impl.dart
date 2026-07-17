import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/checkout_entities.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_datasource.dart';
import '../models/saved_address_model.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SavedAddressEntity>>> getAddresses() async {
    try {
      final data = await remoteDataSource.getAddresses();
      final items = data
          .map((e) => SavedAddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavedAddressEntity>> addAddress(
      SavedAddressEntity address) async {
    try {
      final model = SavedAddressModel(
        id: address.id,
        title: address.title,
        fullName: address.fullName,
        phone: address.phone,
        email: address.email,
        country: address.country,
        city: address.city,
        zipCode: address.zipCode,
        detailedAddress: address.detailedAddress,
        isDefault: address.isDefault,
      );
      await remoteDataSource.addAddress(model.toJson());

      final data = await remoteDataSource.getAddresses();
      if (data.isEmpty) {
        return const Left(
            ServerFailure('Address was saved but could not be loaded'));
      }

      final items = data
          .map((e) => SavedAddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final selected = items.firstWhere(
        (a) => a.isDefault,
        orElse: () => items.first,
      );
      return Right(selected);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitCheckout(
      Map<String, dynamic> checkoutData) async {
    try {
      final response = await remoteDataSource.submitCheckout(checkoutData);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCheckoutData() async {
    try {
      final data = await remoteDataSource.getCheckoutData();
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavedAddressEntity>> editAddress(
      int id, SavedAddressEntity address) async {
    try {
      final model = SavedAddressModel(
        id: address.id,
        title: address.title,
        fullName: address.fullName,
        phone: address.phone,
        email: address.email,
        country: address.country,
        city: address.city,
        zipCode: address.zipCode,
        detailedAddress: address.detailedAddress,
        isDefault: address.isDefault,
      );
      final response = await remoteDataSource.editAddress(id, model.toJson());
      return Right(SavedAddressModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
