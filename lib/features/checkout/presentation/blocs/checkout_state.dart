import 'package:equatable/equatable.dart';
import '../../domain/entities/checkout_entities.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutAddressesLoaded extends CheckoutState {
  final List<SavedAddressEntity> addresses;

  const CheckoutAddressesLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

class CheckoutDataLoaded extends CheckoutState {
  final Map<String, dynamic> data;

  const CheckoutDataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class CheckoutAddressEditSuccess extends CheckoutState {}

class CheckoutSubmitted extends CheckoutState {
  final String orderNumber;

  const CheckoutSubmitted(this.orderNumber);

  @override
  List<Object?> get props => [orderNumber];
}

class CheckoutRedirectToPayment extends CheckoutState {
  final String paymentUrl;
  final String orderNumber;
  final String gateway;

  const CheckoutRedirectToPayment({
    required this.paymentUrl,
    required this.orderNumber,
    required this.gateway,
  });

  @override
  List<Object?> get props => [paymentUrl, orderNumber, gateway];
}

class CheckoutNativePaymentInit extends CheckoutState {
  final String orderNumber;
  final String gateway;
  final String paymentUrl;

  const CheckoutNativePaymentInit({
    required this.orderNumber,
    required this.gateway,
    required this.paymentUrl,
  });

  @override
  List<Object?> get props => [orderNumber, gateway, paymentUrl];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}
