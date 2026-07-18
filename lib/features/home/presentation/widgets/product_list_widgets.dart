import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/kdx_toast.dart';
import '../../domain/entities/product_entity.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../../../wishlist/presentation/blocs/wishlist_bloc.dart';
import '../../../wishlist/presentation/blocs/wishlist_event.dart';
import '../../../wishlist/presentation/blocs/wishlist_state.dart';
import 'product_card.dart';

/// Horizontal scrolling row of product cards — used for Flash Sale & Trending
class ProductHorizontalRow extends StatelessWidget {
  final List<ProductEntity> products;
  final String heroTagPrefix;

  const ProductHorizontalRow({
    super.key,
    required this.products,
    this.heroTagPrefix = 'list',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, wishlistState) {
        return SizedBox(
          height: 270.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (ctx, i) {
              final product = products[i];
              final isWishlisted = wishlistState is WishlistLoaded &&
                  wishlistState.isWishlisted(product.id);
              final heroTag = '${heroTagPrefix}_product_image_${product.id}';
              return SizedBox(
                width: 155.w,
                child: ProductCard(
                  product: product,
                  isWishlisted: isWishlisted,
                  heroTag: heroTag,
                  showAddToCartButton: true,
                  onAddToCart: () {
                    context.read<CartBloc>().add(CartItemAdded(
                          productId: product.id,
                          quantity: 1,
                        ));
                    KdxToast.showSuccess(context, 'the_product_has_been'.tr());
                  },
                  onWishlistTap: () async {
                    if (!await AuthGuard.requireLogin(context)) return;
                    if (!context.mounted) return;
                    context.read<WishlistBloc>().add(
                          WishlistToggleItemRequested(productId: product.id),
                        );
                  },
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(
                          slug: product.slug,
                          heroTag: heroTag,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// 2-column staggered grid for the main product section
class ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, wishlistState) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final product = products[i];
              final isWishlisted = wishlistState is WishlistLoaded &&
                  wishlistState.isWishlisted(product.id);
              final heroTag = 'grid_product_image_${product.id}';
              return ProductCard(
                product: product,
                isWishlisted: isWishlisted,
                heroTag: heroTag,
                onWishlistTap: () async {
                  if (!await AuthGuard.requireLogin(context)) return;
                  if (!context.mounted) return;
                  context.read<WishlistBloc>().add(
                        WishlistToggleItemRequested(productId: product.id),
                      );
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(
                        slug: product.slug,
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
