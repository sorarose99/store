import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productId,
    required super.name,
    super.size,
    required super.imageUrl,
    required super.price,
    required super.quantity,
    required super.total,
    super.sku,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    String img = json['image'] as String? ?? json['image_url'] as String? ?? '';
    if (img.isNotEmpty) {
      img = ApiEndpoints.mediaUrl(img);
    }

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      name: json['product_name'] as String? ?? json['name'] as String? ?? '',
      size: json['size'] as String?,
      imageUrl: img,
      price: _parseDouble(json['price']),
      quantity: _parseInt(json['quantity']),
      total: _parseDouble(json['total']),
      sku: json['sku']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.date,
    required super.status,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.shippingFee,
    super.tax,
    required super.total,
    super.paymentMethod,
    super.paymentStatus,
    super.trackingId,
    super.trackingSteps,
    super.trackingIcons,
    super.shippingFullName,
    super.shippingPhone,
    super.shippingAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    dynamic steps;
    dynamic icons;

    // Handle wrapped response from order detail API
    if (json.containsKey('order') && json['order'] is Map) {
      if (json.containsKey('steps')) {
        steps = json['steps'];
      }
      if (json.containsKey('icons')) {
        icons = json['icons'];
      }
      json = json['order'] as Map<String, dynamic>;
    }

    var itemsList = json['items'] as List? ?? [];
    List<OrderItemModel> items = itemsList
        .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    double shipCost = _parseDouble(json['shipping_cost']);
    if (shipCost == 0.0) {
      shipCost = _parseDouble(json['shipping_fee']);
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      date: json['date'] as String? ?? json['created_at'] as String? ?? '',
      status: json['status'] as String? ?? '',
      items: items,
      subtotal: _parseDouble(json['subtotal']),
      discount: _parseDouble(json['discount']),
      shippingFee: shipCost,
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total']),
      paymentMethod: json['payment_method'] as String?,
      paymentStatus: json['payment_status'] as String?,
      trackingId: json['tracking_id'] as String?,
      trackingSteps: steps,
      trackingIcons: icons,
      shippingFullName: json['shipping_full_name'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      shippingAddress: json['shipping_address'] as String?,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
