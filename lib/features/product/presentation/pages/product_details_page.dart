import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/presentation/widgets/product_list_widgets.dart'; // For similar products row
import '../../domain/entities/product_details_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../widgets/review_widgets.dart';
import '../widgets/notify_size_bottom_sheet.dart';
import '../widgets/add_to_cart_dialog.dart';
import '../pages/product_reviews_page.dart';
import '../../../cart/presentation/widgets/tamara_bottom_sheet.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  // Dummy Data
  final ProductDetailsEntity _productDetails = ProductDetailsEntity(
    baseProduct: const ProductEntity(
      id: 'p1',
      name: 'جاكيت شتوي كلاسيك',
      brand: 'KDX أوريجينالز',
      price: 199.0,
      originalPrice: 299.0,
      imageAsset: 'assets/images/cat_fashion.png',
      isNew: false,
      isSale: true,
      isFreeDelivery: true,
      rating: 4.6,
      reviewCount: 1089,
      isWishlisted: true,
      categoryId: 'c1',
    ),
    imageGallery: [
      'assets/images/cat_fashion.png',
      'assets/images/cat_beauty.png',
      'assets/images/cat_sports.png',
    ],
    description: 'جاكيت شتوي بتصميم أنيق وخطوط ناعمة يمنحك مظهراً مميزاً واحترافياً. مناسب للعمل والمناسبات الرسمية مع خامة مريحة مقاومة للماء والبرودة.',
    availableSizes: ['S', 'M', 'L', 'XL', 'XXL'],
    availableColors: ['أسود داكن', 'أزرق', 'رمادي'],
    ratingDistribution: const {
      5: 0.70,
      4: 0.15,
      3: 0.08,
      2: 0.05,
      1: 0.02,
    },
    reviews: const [
      ReviewEntity(
        id: 'r1',
        userName: 'خديجة محمد',
        userAvatar: 'https://i.pravatar.cc/100?img=1',
        rating: 5.0,
        date: '13/8/2023',
        comment: 'جودة تفوق التوقعات، وتفاصيل دقيقة تأسر الأنظار من النظرة الأولى.',
        likes: 36,
      ),
      ReviewEntity(
        id: 'r2',
        userName: 'مها حسان',
        userAvatar: 'https://i.pravatar.cc/100?img=5',
        rating: 4.0,
        date: '13/8/2023',
        comment: 'بساطة في التصميم وفعالية في الأداء، يحقق الغاية المنشودة بكل سلاسة.',
        likes: 20,
      ),
    ],
    similarProducts: const [
      ProductEntity(
        id: 'sp1',
        name: 'جاكيت شتوي طويل',
        brand: 'KDX',
        price: 249.0,
        originalPrice: 350.0,
        imageAsset: 'assets/images/cat_fashion.png',
        isNew: false,
        isSale: true,
        isFreeDelivery: false,
        rating: 4.8,
        reviewCount: 200,
        isWishlisted: false,
        categoryId: 'c1',
      ),
      ProductEntity(
        id: 'sp2',
        name: 'هودي رجالي بقلنسوة',
        brand: 'KDX بورت',
        price: 129.0,
        originalPrice: 199.0,
        imageAsset: 'assets/images/cat_fashion.png',
        isNew: false,
        isSale: true,
        isFreeDelivery: true,
        rating: 4.9,
        reviewCount: 150,
        isWishlisted: true,
        categoryId: 'c1',
      ),
    ],
  );

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  String _selectedSize = 'L';
  int _selectedVariantIndex = 0; // Replaces _selectedColor — driven by image thumbnail tap
  int _quantity = 1;
  bool _isWishlisted = true;

  @override
  void initState() {
    super.initState();
    _isWishlisted = _productDetails.baseProduct.isWishlisted;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showTamaraSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TamaraBottomSheet(installmentAmount: (_productDetails.baseProduct.price / 3)),
    );
  }

  // Color is now implicitly selected via image thumbnail — no swatch helper needed

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildHeaderInfo(),
                          const SizedBox(height: 16),
                          _buildTamaraBanner(),
                          const SizedBox(height: 24),
                          _buildSizeSelector(),
                          const SizedBox(height: 24),
                          _buildImageVariantPicker(),
                          const SizedBox(height: 24),
                          _buildDeliveryInfo(),
                          const SizedBox(height: 24),
                          const Divider(color: AppColors.border, thickness: 1),
                          const SizedBox(height: 20),
                          _buildDescription(),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border, thickness: 1),
                          const SizedBox(height: 20),
                          _buildReviewsSection(),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border, thickness: 1),
                          const SizedBox(height: 20),
                          _buildAIPromptSection(),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.border, thickness: 1),
                          const SizedBox(height: 20),
                          _buildSimilarProducts(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final hasDiscount = _productDetails.baseProduct.originalPrice != null;
    final discountPct = _productDetails.baseProduct.discountPercent;

    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      expandedHeight: 440.0,
      pinned: true,
      automaticallyImplyLeading: false,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: AppColors.cardShadow,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow,
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textDark, size: 20),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: _isWishlisted ? AppColors.tealGlowShadow : AppColors.cardShadow,
          ),
          child: IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? AppColors.accent : AppColors.textDark,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isWishlisted = !_isWishlisted;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _productDetails.imageGallery.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _productDetails.imageGallery[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black26,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black45,
                    ],
                    stops: [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            // Discount Tag overlay
            if (hasDiscount && discountPct != null)
              Positioned(
                top: kToolbarHeight + 20,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'خصم $discountPct%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            // Horizontal Thumbnail strip overlay at bottom of image
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _productDetails.imageGallery.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _currentImageIndex == index
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        boxShadow: _currentImageIndex == index
                            ? AppColors.tealGlowShadow
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          _productDetails.imageGallery[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    final base = _productDetails.baseProduct;
    final hasDiscount = base.originalPrice != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Name (clickable)
        GestureDetector(
          onTap: () {},
          child: Text(
            base.brand,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Product Name
        Text(
          base.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        // Stars Rating & Reviews Chevron link
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductReviewsPage()),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(5, (i) {
                final full = i < base.rating.floor();
                return Icon(
                  full ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFFFB300),
                  size: 16,
                );
              }),
              const SizedBox(width: 6),
              Text(
                base.rating.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '·  ${base.reviewCount} تقييم',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_left, size: 16, color: AppColors.textGrey),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Price Row with currency "ر.س"
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${base.price.toInt()} ر.س',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: hasDiscount ? AppColors.accent : AppColors.textDark,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 10),
              Text(
                '${base.originalPrice!.toInt()} ر.س',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textGrey,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTamaraBanner() {
    final installmentVal = (_productDetails.baseProduct.price / 3).toStringAsFixed(2);
    return GestureDetector(
      onTap: _showTamaraSheet,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F2), // Light peach Tamara tone
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFE0CC)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9E66),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'تمارا',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'قسّم فاتورتك على 3 دفعات بقيمة $installmentVal ر.س بدون فوائد. لمعرفة المزيد',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_back_ios, textDirection: TextDirection.ltr, size: 12, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'حدد المقاس',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const NotifySizeBottomSheet(),
                );
              },
              child: const Text(
                'دليل المقاسات',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // XS mocked as out of stock
              _buildSizeChip('XS', isAvailable: false),
              ..._productDetails.availableSizes.map((size) => _buildSizeChip(size)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Task 1: Circular Size Chip ─────────────────────────────────────────────
  Widget _buildSizeChip(String size, {bool isAvailable = true}) {
    final isSelected = _selectedSize == size;
    return GestureDetector(
      onTap: isAvailable ? () => setState(() => _selectedSize = size) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isAvailable
                    ? AppColors.border
                    : AppColors.border.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? AppColors.tealGlowShadow
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              size,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isAvailable
                        ? AppColors.textMid
                        : AppColors.textGreyLight,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                fontFamily: 'Tajawal',
              ),
            ),
            if (!isAvailable)
              Positioned.fill(
                child: CustomPaint(
                  painter: _StrikethroughPainter(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Task 2: Image-driven variant picker (replaces color swatches) ───────────
  Widget _buildImageVariantPicker() {
    final gallery = _productDetails.imageGallery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'اختر اللون / التصميم',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            Text(
              '${_selectedVariantIndex + 1} / ${gallery.length}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 68,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedVariantIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVariantIndex = index;
                    _currentImageIndex = index;
                  });
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(left: 12),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: isSelected ? AppColors.tealGlowShadow : null,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      gallery[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'الشحن السريع بواسطة KDX',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'التوصيل مضمون: خلال 4-8 أيام عمل.',
                        style: TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'شحن سريع وآمن مع إمكانية التتبع الكامل لطلبك.',
                        style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل المنتج والمواصفات',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Text(
          _productDetails.description,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMid,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewDistributionWidget(
          distribution: _productDetails.ratingDistribution,
          averageRating: _productDetails.baseProduct.rating,
          totalReviews: _productDetails.baseProduct.reviewCount,
        ),
        const SizedBox(height: 20),
        ..._productDetails.reviews.map((r) => ReviewCardWidget(review: r)),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProductReviewsPage()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: const Text(
              'عرض كل الآراء والتقييمات',
              style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'منتجات قد تعجبك أيضاً',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'عرض الكل',
                style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProductHorizontalRow(products: _productDetails.similarProducts),
      ],
    );
  }

  Widget _buildAIPromptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اسأل خبير الموضة الذكي',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        const Text(
          'هل تريد معرفة كيف تنسق هذه القطعة مع ملابس أخرى؟ أو تسأل عن تفاصيل دقيقة للمنتج؟',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'اكتب سؤالك هنا...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textGreyLight),
                  ),
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري تحليل سؤالك...')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity Selector
            Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppColors.textMid, size: 18),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    _quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.textMid, size: 18),
                    onPressed: () {
                      setState(() => _quantity++);
                    },
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to Cart Button (Namshe-style Gradient with Shopping Bag icon)
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: AppColors.tealGlowShadow,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddToCartDialog(),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                  label: const Text(
                    'أضف إلى السلة',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper: diagonal line painter for out-of-stock circles ──────────────────
class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textGreyLight
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
