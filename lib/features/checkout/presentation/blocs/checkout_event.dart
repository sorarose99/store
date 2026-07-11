import 'package:equatable/equatable.dart';
import '../../domain/entities/checkout_entities.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutAddressesRequested extends CheckoutEvent {
  const CheckoutAddressesRequested();
}

class CheckoutAddressAdded extends CheckoutEvent {
  final SavedAddressEntity address;

  const CheckoutAddressAdded(this.address);

  @override
  List<Object?> get props => [address];
}

class CheckoutSubmitRequested extends CheckoutEvent {
  final Map<String, dynamic> checkoutData;

  const CheckoutSubmitRequested(this.checkoutData);

  @override
  List<Object?> get props => [checkoutData];
}

class CheckoutDataRequested extends CheckoutEvent {
  const CheckoutDataRequested();
}

class CheckoutAddressEdited extends CheckoutEvent {
  final int id;
  final SavedAddressEntity address;

  const CheckoutAddressEdited(this.id, this.address);

  @override
  List<Object?> get props => [id, address];
}
