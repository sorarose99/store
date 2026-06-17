import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../cart/presentation/pages/cart_filled_page.dart';
import 'wishlist_empty_page.dart';

class WishlistFilledPage extends StatefulWidget {
  const WishlistFilledPage({super.key});

  @override
  State<WishlistFilledPage> createState() => _WishlistFilledPageState();
}

class _WishlistFilledPageState extends State<WishlistFilledPage> {
  // Mock Wishlist Items (made mutable)
  late List<ProductEntity> _wishlistItems;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _wishlistItems = List.generate(
      6,
      (index) => ProductEntity(
        id: 'w$index',
        name: index % 2 == 0 ? 'جاكيت شتوي كاجوال أنيق' : 'فستان سهرة كلاسيك ذو تفاصيل دقيقة',
        brand: 'KDX أوريجينالز',
        price: 180.0 + (index * 15),
        originalPrice: 240.0 + (index * 20),
        imageAsset: 'assets/images/cat_fashion.png',
        isNew: index % 2 == 0,
        isSale: index % 3 == 0,
        isFreeDelivery: true,
        rating: 4.5 + (index * 0.1 > 0.5 ? 0.4 : index * 0.1),
        reviewCount: 120 + (index * 12),
        isWishlisted: true,
        categoryId: 'c2',
      ),
    );
  }

  void _removeItem(String id) {
    setState(() {
      _wishlistItems.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تمت إزالة المنتج من المفضلة',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_wishlistItems.isEmpty) {
      return const WishlistEmptyPage();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'المفضلة',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: Column(
          children: [
            // Search & Action Row Below AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Grid/List toggle button
                  GestureDetector(
                    onTap: () => setState(() => _isGridView = !_isGridView),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Search Input "ابحث..." with search icon
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: AppColors.textGrey, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'ابحث...',
                                hintStyle: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 13,
                                  fontFamily: 'Tajawal',
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 13,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Filter Button
                  GestureDetector(
                    onTap: () {
                      // Filter action
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Shopping Bag Badge
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartFilledPage()),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F3F8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.textDark,
                            size: 20,
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Grid or List
            Expanded(
              child: _isGridView ? _buildGridView() : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.48, // Compact layout for 3 columns
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: _wishlistItems.length,
      itemBuilder: (context, index) {
        final product = _wishlistItems[index];
        return CompactWishlistCard(
          product: product,
          onWishlistTap: () => _removeItem(product.id),
          onTap: () {
            // Product detail view action
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _wishlistItems.length,
      itemBuilder: (context, index) {
        final product = _wishlistItems[index];
        return _HorizontalWishlistItemCard(
          product: product,
          onDelete: () => _removeItem(product.id),
          onAddToCart: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تمت إضافة المنتج إلى السلة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                ),
                duration: Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Compact Wishlist Card for 3-Column Layout ────────────────────────────────
class CompactWishlistCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onWishlistTap;
  final VoidCallback onTap;

  const CompactWishlistCard({
    super.key,
    required this.product,
    required this.onWishlistTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.originalPrice != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Heart overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: AspectRatio(
                    aspectRatio: 0.76,
                    child: Image.asset(
                      product.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF2F3F8),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textGrey,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: onWishlistTap,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFE53935),
                        size: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Product info details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'Tajawal',
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB300),
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                    
                    // Price Tag
                    Row(
                      children: [
                        Text(
                          '${product.price.toInt()} ر.س',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${product.originalPrice!.toInt()}',
                            style: const TextStyle(
                              fontSize: 8.5,
                              color: AppColors.textGrey,
                              decoration: TextDecoration.lineThrough,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Horizontal Card Layout for List View
class _HorizontalWishlistItemCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onDelete;
  final VoidCallback onAddToCart;

  const _HorizontalWishlistItemCard({
    required this.product,
    required this.onDelete,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.originalPrice != null;
    final discountPct = product.discountPercent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section (3:4 aspect ratio styled)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: Image.asset(
                  product.imageAsset,
                  width: 90,
                  height: 124,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 124,
                    color: AppColors.cardBackground,
                    child: const Icon(Icons.image_outlined, color: AppColors.textGreyLight),
                  ),
                ),
              ),
              if (hasDiscount && discountPct != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$discountPct%−',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Name
                  Text(
                    product.brand,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rating Row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount})',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textGrey,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Price and Add to Cart Row
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Text(
                              '${product.originalPrice!.toInt()} ر.س',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textGrey,
                                decoration: TextDecoration.lineThrough,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          Text(
                            '${product.price.toInt()} ر.س',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: hasDiscount ? AppColors.accent : AppColors.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Add to Cart Button (teal chip button)
                      ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.shopping_bag_outlined, size: 12, color: Colors.white),
                        label: const Text(
                          'أضف للسلة',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delete Action Floater
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textGrey, size: 18),
            onPressed: onDelete,
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }
}
