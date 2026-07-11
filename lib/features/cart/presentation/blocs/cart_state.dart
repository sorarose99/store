import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartCountLoaded extends CartState {
  final int count;
  const CartCountLoaded(this.count);
  @override
  List<Object?> get props => [count];
}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final String? appliedCouponCode;
  final double couponDiscount;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double total;
  final List<Map<String, dynamic>> zones;
  final int? selectedZone;

  const CartLoaded({
    required this.items,
    this.appliedCouponCode,
    this.couponDiscount = 0.0,
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.shippingCost = 0.0,
    this.total = 0.0,
    this.zones = const [],
    this.selectedZone,
  });

  CartLoaded copyWith({
    List<CartItemEntity>? items,
    String? appliedCouponCode,
    double? couponDiscount,
    double? subtotal,
    double? taxAmount,
    double? shippingCost,
    double? total,
    List<Map<String, dynamic>>? zones,
    int? selectedZone,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      zones: zones ?? this.zones,
      selectedZone: selectedZone ?? this.selectedZone,
    );
  }

  @override
  List<Object?> get props => [
        items,
        appliedCouponCode,
        couponDiscount,
        subtotal,
        taxAmount,
        shippingCost,
        total,
        zones,
        selectedZone,
      ];
}

class CartError extends CartState {
  final String message;
  final List<CartItemEntity>? previousItems;

  const CartError(this.message, {this.previousItems});

  @override
  List<Object?> get props => [message, previousItems];
}
