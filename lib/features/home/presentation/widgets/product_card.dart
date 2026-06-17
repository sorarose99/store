import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/constants/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Namshe-style ProductCard
// Editorial 3:4 ratio image, pill badges, star rating, teal delivery chip
// ─────────────────────────────────────────────────────────────────────────────
class ProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onTap;
  final bool showAddToCartButton;

  const ProductCard({
    super.key,
    required this.product,
    this.onWishlistTap,
    this.onTap,
    this.showAddToCartButton = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.product.isWishlisted;
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleWishlist() {
    setState(() => _isWishlisted = !_isWishlisted);
    _heartController.forward(from: 0);
    widget.onWishlistTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasDiscount = product.originalPrice != null;
    final discountPct = product.discountPercent;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + Badges + Wishlist ──────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Product image — 3:4 editorial ratio
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.asset(
                      product.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardBackground,
                        child: const Center(
                          child: Icon(Icons.image_outlined,
                              size: 44, color: AppColors.textGreyLight),
                        ),
                      ),
                    ),
                  ),

                  // Discount badge — pill shape, Namshe red
                  if (hasDiscount && discountPct != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$discountPct%−',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                  // NEW badge — teal pill
                  if (product.isNew && !hasDiscount)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'جديد',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist heart button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: _handleWishlist,
                      child: ScaleTransition(
                        scale: _heartScale,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: _isWishlisted
                                ? AppColors.tealGlowShadow
                                : AppColors.cardShadow,
                          ),
                          child: Icon(
                            _isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            color: _isWishlisted
                                ? AppColors.accent
                                : AppColors.textGrey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Brand logo pill at bottom of image
                  if (product.brand.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.brand,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Product Info ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 5),

                  // Star rating row
                  const _StarRatingRow(rating: 4.2, reviewCount: 48),
                  const SizedBox(height: 7),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          '${product.originalPrice!.toInt()} ر.س',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        '${product.price.toInt()} ر.س',
                        style: TextStyle(
                          fontSize: 15,
                          color: hasDiscount
                              ? AppColors.accent
                              : AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  // Free delivery chip
                  if (product.isFreeDelivery) ...[
                    const SizedBox(height: 6),
                    _FreeDeliveryChip(),
                  ],

                  // Add to Cart Button for Wishlist
                  if (widget.showAddToCartButton) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تمت إضافة المنتج إلى السلة', style: TextStyle(fontWeight: FontWeight.bold)),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.white),
                        label: const Text(
                          'أضف إلى السلة',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Star Rating Row
// ─────────────────────────────────────────────────────────────────────────────
class _StarRatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const _StarRatingRow({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '($reviewCount)',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 3),
        ...List.generate(5, (i) {
          final full = i < rating.floor();
          final half = !full && i < rating.ceil() && (rating % 1) >= 0.3;
          return Icon(
            full
                ? Icons.star_rounded
                : half
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            color: const Color(0xFFFFB300),
            size: 13,
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Free Delivery Chip
// ─────────────────────────────────────────────────────────────────────────────
class _FreeDeliveryChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: AppColors.success.withAlpha(80), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.local_shipping_outlined,
              size: 11, color: AppColors.success),
          SizedBox(width: 3),
          Text(
            'توصيل مجاني',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
