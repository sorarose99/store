import 'package:equatable/equatable.dart';
import '../../../checkout/domain/entities/checkout_entities.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<SavedAddressEntity> addresses;

  const AddressLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class AddressActionLoading extends AddressState {}

class AddressActionSuccess extends AddressState {
  final String message;

  const AddressActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressActionError extends AddressState {
  final String message;

  const AddressActionError(this.message);

  @override
  List<Object?> get props => [message];
}
