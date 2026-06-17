class CartItemEntity {
  final String id;
  final String productId;
  final String name;
  final String size;
  final String color;
  final double price;
  final int quantity;
  final String imageUrl;
  final bool isAvailable;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.name,
    required this.size,
    required this.color,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.isAvailable = true,
  });
}
