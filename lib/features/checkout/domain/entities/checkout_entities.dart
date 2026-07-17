// =============================================================================
// DOMAIN LAYER — Checkout Entities
// API-ready immutable data classes for the checkout feature
// =============================================================================

/// Represents a saved delivery address
class SavedAddressEntity {
  final String id;
  final String title;
  final String fullName;
  final String phone;
  final String email;
  final String country;
  final String city;
  final String zipCode;
  final String detailedAddress;
  final bool isDefault;

  SavedAddressEntity({
    required this.id,
    required this.title,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.country,
    required this.city,
    required this.zipCode,
    required this.detailedAddress,
    this.isDefault = false,
  });

  factory SavedAddressEntity.fromJson(Map<String, dynamic> json) {
    return SavedAddressEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      zipCode: json['postal_code']?.toString() ?? '',
      detailedAddress: json['address']?.toString() ?? '',
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }

  String get fullAddress => detailedAddress.isNotEmpty ? detailedAddress : city;
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
