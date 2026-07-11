// =============================================================================
// DOMAIN LAYER — Checkout Entities
// API-ready immutable data classes for the checkout feature
// =============================================================================

/// Represents a saved delivery address
class SavedAddressEntity {
  final String id;
  final String recipientName;
  final String phone;
  final String city;
  final String district;
  final String street;
  final String buildingNo;
  final String floor;
  final String zipCode;
  final bool isDefault;

  SavedAddressEntity({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.city,
    required this.district,
    required this.street,
    required this.buildingNo,
    required this.floor,
    required this.zipCode,
    this.isDefault = false,
  });

  factory SavedAddressEntity.fromJson(Map<String, dynamic> json) {
    return SavedAddressEntity(
      id: json['id']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      buildingNo: json['buildingNo']?.toString() ?? '',
      floor: json['floor']?.toString() ?? '',
      zipCode: json['zipCode']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
    );
  }

  String get fullAddress => '$street، $district، $city';
}

/// Represents a single product item in the cart during checkout
class CartItemEntity {
  final String productId;
  final String name;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;
  final String imageUrl;

  const CartItemEntity({
    required this.productId,
    required this.name,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
  });

  double get totalPrice => unitPrice * quantity;
}

/// Price breakdown summary for order review
class CheckoutSummaryEntity {
  final double subtotal;
  final double discount;
  final double shippingFee;
  final double tax;
  final double total;
  final int itemCount;

  const CheckoutSummaryEntity({
    required this.subtotal,
    required this.discount,
    required this.shippingFee,
    required this.tax,
    required this.total,
    required this.itemCount,
  });
}

/// Payment method option
class PaymentMethodEntity {
  final String id;
  final String name;
  final String? subtitle;
  final PaymentMethodType type;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    this.subtitle,
    required this.type,
  });
}

enum PaymentMethodType { applePay, creditCard, cashOnDelivery, wallet }
