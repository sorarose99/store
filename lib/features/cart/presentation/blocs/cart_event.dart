import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartRequested extends CartEvent {
  const CartRequested();
}

class CartItemAdded extends CartEvent {
  final String productId;
  final int quantity;
  final int? imageId;
  final String? sizeName;

  const CartItemAdded({
    required this.productId,
    required this.quantity,
    this.imageId,
    this.sizeName,
  });

  @override
  List<Object?> get props => [productId, quantity, imageId, sizeName];
}

class CartItemUpdated extends CartEvent {
  final String productId;
  final int quantity;
  final List<Map<String, dynamic>>? breakdown;

  const CartItemUpdated(
      {required this.productId, required this.quantity, this.breakdown});

  @override
  List<Object?> get props => [productId, quantity, breakdown];
}

class CartItemOptimisticUpdated extends CartEvent {
  final String productId;
  final int quantity;
  final List<Map<String, dynamic>>? breakdown;

  const CartItemOptimisticUpdated(
      {required this.productId, required this.quantity, this.breakdown});

  @override
  List<Object?> get props => [productId, quantity, breakdown];
}

class CartItemBreakdownUpdated extends CartEvent {
  final String productId;
  final List<Map<String, dynamic>> breakdown;

  const CartItemBreakdownUpdated(
      {required this.productId, required this.breakdown});

  @override
  List<Object?> get props => [productId, breakdown];
}

class CartItemRemoved extends CartEvent {
  final String productId;

  const CartItemRemoved({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class CartCouponApplied extends CartEvent {
  final String code;

  const CartCouponApplied({required this.code});

  @override
  List<Object?> get props => [code];
}

class CartCouponRemoved extends CartEvent {
  const CartCouponRemoved();
}

class CartShippingZoneUpdated extends CartEvent {
  final int zoneId;

  const CartShippingZoneUpdated({required this.zoneId});

  @override
  List<Object?> get props => [zoneId];
}

class CartCountRequested extends CartEvent {
  const CartCountRequested();
}

class CartCleared extends CartEvent {
  const CartCleared();
}
