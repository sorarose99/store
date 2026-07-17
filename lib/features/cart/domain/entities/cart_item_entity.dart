class CartItemEntity {
  final String id;
  final String productId;
  final String name;
  final String slug;
  final String size;
  final String color;
  final double price;
  final int quantity;
    final String imageUrl;
    final List<Map<String, dynamic>> breakdown;
    final List<String> productSizes;
    final bool isAvailable;
    final bool requiresShipping;
  
    const CartItemEntity({
      required this.id,
      required this.productId,
      required this.name,
      required this.slug,
      required this.size,
      required this.color,
      required this.price,
      required this.quantity,
      required this.imageUrl,
      this.isAvailable = true,
      this.breakdown = const [],
      this.productSizes = const [],
      this.requiresShipping = true,
    });
  
    CartItemEntity copyWith({
      String? id,
      String? productId,
      String? name,
      String? slug,
      String? size,
      String? color,
      double? price,
      int? quantity,
      String? imageUrl,
      bool? isAvailable,
      List<Map<String, dynamic>>? breakdown,
      List<String>? productSizes,
      bool? requiresShipping,
    }) {
      return CartItemEntity(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        name: name ?? this.name,
        slug: slug ?? this.slug,
        size: size ?? this.size,
        color: color ?? this.color,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      breakdown: breakdown ?? this.breakdown,
      productSizes: productSizes ?? this.productSizes,
      requiresShipping: requiresShipping ?? this.requiresShipping,
    );
  }
}
