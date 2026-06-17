import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../widgets/filter_bottom_sheet.dart';

class ProductGridPage extends StatefulWidget {
  final String categoryName;

  const ProductGridPage({
    super.key,
    required this.categoryName,
  });

  @override
  State<ProductGridPage> createState() => _ProductGridPageState();
}

class _ProductGridPageState extends State<ProductGridPage> {
  // Dummy products based on existing home feature model
  final List<ProductEntity> _products = [
    const ProductEntity(
      id: 'p1',
      name: 'فستان ماكسي كاجوال',
      brand: 'زينة',
      price: 25.0,
      originalPrice: 35.0,
      imageAsset: 'assets/images/cat_fashion.png',
      isNew: false,
      isSale: true,
      isFreeDelivery: true,
      rating: 4.8,
      reviewCount: 120,
      isWishlisted: true,
      discountLabel: '28%',
      categoryId: 'c1',
    ),
    const ProductEntity(
      id: 'p2',
      name: 'فستان صيفي مزين',
      brand: 'أناقة',
      price: 26.0,
      originalPrice: 30.0,
      imageAsset: 'assets/images/cat_fashion.png',
      isNew: true,
      isSale: false,
      isFreeDelivery: false,
      rating: 4.5,
      reviewCount: 85,
      isWishlisted: false,
      categoryId: 'c1',
    ),
    const ProductEntity(
      id: 'p3',
      name: 'فستان أنيق للسهرة',
      brand: 'سحر',
      price: 45.0,
      imageAsset: 'assets/images/cat_fashion.png',
      isNew: false,
      isSale: false,
      isFreeDelivery: true,
      rating: 4.9,
      reviewCount: 340,
      isWishlisted: false,
      categoryId: 'c1',
    ),
    const ProductEntity(
      id: 'p4',
      name: 'فستان كلاسيكي أسود',
      brand: 'مودرن',
      price: 32.0,
      originalPrice: 40.0,
      imageAsset: 'assets/images/cat_fashion.png',
      isNew: false,
      isSale: true,
      isFreeDelivery: true,
      rating: 4.6,
      reviewCount: 210,
      isWishlisted: true,
      discountLabel: '20%',
      categoryId: 'c1',
    ),
  ];

  final String _selectedSort = 'الافتراضي';

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSortAndFilterRow(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Container(
        height: 38,
        margin: const EdgeInsets.only(left: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textGrey, size: 18),
            const SizedBox(width: 8),
            Text(
              widget.categoryName,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSortAndFilterRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Button
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Row(
              children: const [
                Icon(Icons.tune, size: 18, color: AppColors.textDark),
                SizedBox(width: 6),
                Text(
                  'تصفية النتائج',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          
          // Sort Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  _selectedSort,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.48,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return CompactProductCard(
          product: product,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailsPage(productId: product.id),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Compact Product Card for 3-Column Layout ────────────────────────────────
class CompactProductCard extends StatefulWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  const CompactProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<CompactProductCard> createState() => _CompactProductCardState();
}

class _CompactProductCardState extends State<CompactProductCard> {
  late bool _isWishlisted;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.product.isWishlisted;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasDiscount = product.originalPrice != null;

    return GestureDetector(
      onTap: widget.onTap,
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
                    aspectRatio: 0.75,
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
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isWishlisted = !_isWishlisted;
                      });
                    },
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
                      child: Icon(
                        _isWishlisted ? Icons.favorite : Icons.favorite_border_rounded,
                        color: _isWishlisted ? const Color(0xFFE53935) : AppColors.textGrey,
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
