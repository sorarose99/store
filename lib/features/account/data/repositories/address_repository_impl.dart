import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../checkout/data/models/saved_address_model.dart';
import '../../../checkout/domain/entities/checkout_entities.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

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
        recipientName: address.recipientName,
        phone: address.phone,
        city: address.city,
        district: address.district,
        street: address.street,
        buildingNo: address.buildingNo,
        floor: address.floor,
        zipCode: address.zipCode,
        isDefault: address.isDefault,
      );
      final response = await remoteDataSource.addAddress(model.toJson());
      if (response.containsKey('address') && response['address'] is Map) {
        final addressJson = response['address'] as Map<String, dynamic>;
        return Right(SavedAddressModel.fromJson(addressJson));
      } else {
        final fallbackId = model.id.isNotEmpty
            ? model.id
            : 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final fallbackModel = SavedAddressModel(
          id: fallbackId,
          recipientName: model.recipientName,
          phone: model.phone,
          city: model.city,
          district: model.district,
          street: model.street,
          buildingNo: model.buildingNo,
          floor: model.floor,
          zipCode: model.zipCode,
          isDefault: model.isDefault,
        );
        return Right(fallbackModel);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavedAddressEntity>> updateAddress(
      String id, SavedAddressEntity address) async {
    try {
      final model = SavedAddressModel(
        id: address.id,
        recipientName: address.recipientName,
        phone: address.phone,
        city: address.city,
        district: address.district,
        street: address.street,
        buildingNo: address.buildingNo,
        floor: address.floor,
        zipCode: address.zipCode,
        isDefault: address.isDefault,
      );
      final response = await remoteDataSource.updateAddress(id, model.toJson());
      if (response.containsKey('address') && response['address'] is Map) {
        final addressJson = response['address'] as Map<String, dynamic>;
        return Right(SavedAddressModel.fromJson(addressJson));
      } else {
        return Right(model);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String id) async {
    try {
      await remoteDataSource.deleteAddress(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
