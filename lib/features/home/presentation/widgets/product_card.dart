import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/kdx_toast.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Namshe-style ProductCard
// Editorial 3:4 ratio image, pill badges, star rating, teal delivery chip
// ─────────────────────────────────────────────────────────────────────────────
class ProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool showAddToCartButton;
  final bool isWishlisted;
  final String? heroTag;

  const ProductCard({
    super.key,
    required this.product,
    this.onWishlistTap,
    this.onTap,
    this.onAddToCart,
    this.showAddToCartButton = false,
    this.isWishlisted = false,
    this.heroTag,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _heartController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleWishlist() {
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
          color: context.surfaceColor,
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
                    child: Hero(
                      tag: widget.heroTag ?? 'product_image_${widget.product.id}',
                      child: product.imageAsset.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: product.imageAsset,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  _buildPlaceholder(context),
                            )
                          : Image.asset(
                              product.imageAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholder(context),
                            ),
                    ),
                  ),
                  // Wishlist Icon Overlay
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: _handleWishlist,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ScaleTransition(
                          scale: _heartScale,
                          child: Icon(
                            widget.isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.isWishlisted
                                ? context.errorColor
                                : context.textGrey,
                            size: 18.sp,
                          ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textDark,
                      fontFamily: 'Tajawal',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),

                  SizedBox(height: 8.h),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasDiscount && discountPct != null) ...[
                        Text(
                          '$discountPct%-',
                          style: TextStyle(
                            color:
                                context.errorColor, // Namshi red discount text
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${product.originalPrice!.toInt()} ﷼',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.textGrey,
                            decoration: TextDecoration.lineThrough,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        '${product.price.toInt()} ﷼',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: context.textDark,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Today badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: context.primaryColor, // Namshi bright green/yellow
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'today'.tr(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: context.onPrimary,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),

                  // Add to Cart Button for Wishlist & Product Cards
                  if (widget.showAddToCartButton || widget.onAddToCart != null) ...[
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (widget.onAddToCart != null) {
                            widget.onAddToCart!();
                          } else {
                            context.read<CartBloc>().add(CartItemAdded(
                                  productId: widget.product.id,
                                  quantity: 1,
                                ));
                            KdxToast.showSuccess(
                                context, 'the_product_has_been'.tr());
                          }
                        },
                        icon: Icon(Icons.shopping_bag_outlined,
                            size: 14, color: context.backgroundColor),
                        label: Text(
                          'add_to_cart'.tr(),
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: context.backgroundColor),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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

  Widget _buildPlaceholder(BuildContext context) {
    final validFallbacks = [0, 3, 9];
    final index = validFallbacks[
        widget.product.id.hashCode.abs() % validFallbacks.length];
    return Image.asset(
      'assets/images/fallback_cat_$index.png',
      fit: BoxFit.cover,
    );
  }
}
