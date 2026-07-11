import 'package:equatable/equatable.dart';
import '../../../checkout/domain/entities/checkout_entities.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddresses extends AddressEvent {}

class AddAddress extends AddressEvent {
  final SavedAddressEntity address;

  const AddAddress(this.address);

  @override
  List<Object?> get props => [address];
}

class UpdateAddress extends AddressEvent {
  final String id;
  final SavedAddressEntity address;

  const UpdateAddress({required this.id, required this.address});

  @override
  List<Object?> get props => [id, address];
}

class DeleteAddress extends AddressEvent {
  final String id;

  const DeleteAddress(this.id);

  @override
  List<Object?> get props => [id];
}
