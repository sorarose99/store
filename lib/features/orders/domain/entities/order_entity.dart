// ─────────────────────────────────────────────────────────────────────────────
// Order Entities
// ─────────────────────────────────────────────────────────────────────────────

class OrderItemEntity {
  final String id;
  final String name;
  final String size;
  final String imageUrl;
  final double price;
  final int quantity;

  const OrderItemEntity({
    required this.id,
    required this.name,
    required this.size,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
}

class OrderEntity {
  final String id;
  final String orderNumber;
  final String date;
  final String status;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double total;
  final String? trackingId;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.total,
    this.trackingId,
  });

  double get itemsCount => items.fold(0, (sum, i) => sum + i.quantity);
}
