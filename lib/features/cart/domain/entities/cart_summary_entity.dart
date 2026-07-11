import 'cart_item_entity.dart';

class CartSummaryEntity {
  final List<CartItemEntity> items;
  final double subtotal;
  final double taxAmount;
  final double shippingCost;
  final double discount;
  final double total;
  final List<Map<String, dynamic>> zones;
  final int? selectedZone;

  const CartSummaryEntity({
    required this.items,
    this.subtotal = 0.0,
    this.taxAmount = 0.0,
    this.shippingCost = 0.0,
    this.discount = 0.0,
    this.total = 0.0,
    this.zones = const [],
    this.selectedZone,
  });

  CartSummaryEntity copyWith({
    List<CartItemEntity>? items,
    double? subtotal,
    double? taxAmount,
    double? shippingCost,
    double? discount,
    double? total,
    List<Map<String, dynamic>>? zones,
    int? selectedZone,
  }) {
    return CartSummaryEntity(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      zones: zones ?? this.zones,
      selectedZone: selectedZone ?? this.selectedZone,
    );
  }
}
