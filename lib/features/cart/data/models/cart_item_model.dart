import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.name,
    required super.slug,
    required super.size,
    required super.color,
    required super.price,
    required super.quantity,
    required super.imageUrl,
    super.isAvailable = true,
    super.breakdown,
    super.productSizes,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final prodId = json['product_id']?.toString() ??
        json['id']?.toString() ??
        json['cart_item_id']?.toString() ??
        '';
    final imgUrl =
        json['image_url'] as String? ?? json['image'] as String? ?? '';
    return CartItemModel(
      id: json['cart_item_id']?.toString() ?? json['id']?.toString() ?? '',
      productId: prodId,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ??
          json['name'] as String? ??
          json['product_id']?.toString() ??
          json['id']?.toString() ??
          '',
      size: json['size'] as String? ?? '',
      color: json['color'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: imgUrl,
      isAvailable: json['is_available'] as bool? ?? true,
      breakdown: (json['breakdown'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      productSizes: (json['product_sizes'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map) {
                  return e['name']?.toString() ?? '';
                }
                return e?.toString() ?? '';
              })
              .where((name) => name.isNotEmpty)
              .toList() ??
          [],
    );
  }
}
