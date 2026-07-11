// ─────────────────────────────────────────────────────────────────────────────
// Order Entities
// ─────────────────────────────────────────────────────────────────────────────

class OrderItemEntity {
  final String id;
  final String productId;
  final String name;
  final String? size;
  final String imageUrl;
  final double price;
  final int quantity;
  final double total;
  final String? sku;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.name,
    this.size,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.total,
    this.sku,
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
  final double tax;
  final double total;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? trackingId;
  final dynamic trackingSteps;
  final dynamic trackingIcons;

  final String? shippingFullName;
  final String? shippingPhone;
  final String? shippingAddress;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    this.tax = 0.0,
    required this.total,
    this.paymentMethod,
    this.paymentStatus,
    this.trackingId,
    this.trackingSteps,
    this.trackingIcons,
    this.shippingFullName,
    this.shippingPhone,
    this.shippingAddress,
  });

  double get itemsCount => items.fold(0, (sum, i) => sum + i.quantity);
}
