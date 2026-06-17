import 'package:flutter/material.dart';
import '../../domain/entities/product_entity.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import 'product_card.dart';

/// Horizontal scrolling row of product cards — used for Flash Sale & Trending
class ProductHorizontalRow extends StatelessWidget {
  final List<ProductEntity> products;
  final ValueChanged<String>? onWishlistTap;

  const ProductHorizontalRow({
    super.key,
    required this.products,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final product = products[i];
          return SizedBox(
            width: 155,
            child: ProductCard(
              product: product,
              onWishlistTap: () => onWishlistTap?.call(product.id),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsPage(productId: product.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// 2-column staggered grid for the main product section
class ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;
  final ValueChanged<String>? onWishlistTap;

  const ProductGrid({
    super.key,
    required this.products,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          return ProductCard(
            product: product,
            onWishlistTap: () => onWishlistTap?.call(product.id),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailsPage(productId: product.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
