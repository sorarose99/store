import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../home/presentation/widgets/product_list_widgets.dart'; // For similar products row
import '../../domain/entities/product_details_entity.dart';
import '../../../search_filter/presentation/pages/product_grid_page.dart';
import '../blocs/product_details_cubit.dart';
import '../blocs/product_details_state.dart';
import '../widgets/review_widgets.dart';
import '../widgets/add_to_cart_dialog.dart';
import '../pages/product_reviews_page.dart';
import 'product_specs_page.dart';
import '../../../cart/presentation/widgets/tamara_bottom_sheet.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../delivery_options/presentation/widgets/delivery_options_widget.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
import '../../../wishlist/presentation/blocs/wishlist_bloc.dart';
import '../../../wishlist/presentation/blocs/wishlist_event.dart';
import '../../../wishlist/presentation/blocs/wishlist_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/utils/auth_guard.dart';

class ProductDetailsPage extends StatelessWidget {
  final String slug;
  final String? heroTag;

  const ProductDetailsPage({super.key, required this.slug, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProductDetailsCubit>()..fetchProductDetails(slug),
      child: _ProductDetailsView(heroTag: heroTag),
    );
  }
}

class _ProductDetailsView extends StatefulWidget {
  final String? heroTag;
  const _ProductDetailsView({this.heroTag});

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  ProductDetailsEntity? _productDetails;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  int? _selectedVariantIndex; // Driven by image thumbnail tap
  int? _selectedSizeIndex;
  int _quantity = 1;
  bool _triedToAdd = false; // tracks if user tapped Add to Cart without selecting

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showTamaraSheet() {
    if (_productDetails == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TamaraBottomSheet(
          installmentAmount: (_productDetails!.baseProduct.price / 3)),
    );
  }

  // Color is now implicitly selected via image thumbnail — no swatch helper needed

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        body: BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
          listener: (context, state) {
            if (state is ProductDetailsLoaded) {
              setState(() {
                _productDetails = state.productDetails;
                // Auto-select ONLY if there is a single choice
                final sizes = state.productDetails.availableSizes.where((s) => s.trim().isNotEmpty).toList();
                if (sizes.length == 1) {
                  _selectedSizeIndex = 0;
                } else {
                  _selectedSizeIndex = null;
                }
                // Auto-select variant when there are 0 or 1 distinct colors
                // (gallery images are angle shots, not color options).
                // Only require manual selection when there are >1 real color variants.
                final requiresVariantSelection = state.productDetails.imageGallery.length > 1;
                if (!requiresVariantSelection) {
                  _selectedVariantIndex = 0;
                } else {
                  _selectedVariantIndex = null;
                }
              });
            }
          },
          builder: (context, state) {
            if (state is ProductDetailsLoading ||
                state is ProductDetailsInitial) {
              return Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(
                        width: double.infinity,
                        height: 400.h,
                        borderRadius: 12),
                    SizedBox(height: 24.h),
                    AppShimmer(width: 200.w, height: 24.h),
                    SizedBox(height: 12.h),
                    AppShimmer(width: 150.w, height: 20.h),
                    SizedBox(height: 32.h),
                    AppShimmer(
                        width: double.infinity, height: 60.h, borderRadius: 8),
                  ],
                ),
              );
            } else if (state is ProductDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message,
                        style: TextStyle(
                            color: context.errorColor, fontSize: 16.sp)),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('back'.tr()),
                    )
                  ],
                ),
              );
            }

            if (state is ProductDetailsLoaded) {
              if (_productDetails == null || _productDetails!.baseProduct.id != state.productDetails.baseProduct.id) {
                _productDetails = state.productDetails;
                final sizes = _productDetails!.availableSizes.where((s) => s.trim().isNotEmpty).toList();
                if (sizes.length == 1) {
                  _selectedSizeIndex = 0;
                } else {
                  _selectedSizeIndex = null;
                }
                // Require variant selection if there are multiple images.
                final requiresVariantSelection = _productDetails!.imageGallery.length > 1;
                if (!requiresVariantSelection) {
                  _selectedVariantIndex = 0;
                } else {
                  _selectedVariantIndex = null;
                }
              }
            }

            if (_productDetails == null) return const SizedBox.shrink();

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(context),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h),
                              _buildHeaderInfo(context),
                              SizedBox(height: 16.h),
                              _buildTamaraBanner(context),
                              SizedBox(height: 24.h),
                              SizedBox(height: 24.h),
                              _buildImageVariantPicker(context),
                              if (_productDetails!
                                  .availableSizes.isNotEmpty) ...[
                                SizedBox(height: 24.h),
                                _buildSizePicker(context),
                              ],
                              SizedBox(height: 24.h),
                              const DeliveryOptionsWidget(),
                              SizedBox(height: 24.h),
                              Divider(color: context.border, thickness: 1),
                              SizedBox(height: 20.h),
                              _buildDescription(context),
                              SizedBox(height: 20.h),
                              Divider(color: context.border, thickness: 1),
                              SizedBox(height: 20.h),
                              _buildReviewsSection(context),
                              SizedBox(height: 20.h),
                              _buildSimilarProducts(context),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildBottomBar(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final hasDiscount = _productDetails!.baseProduct.originalPrice != null;
    final discountPct = _productDetails!.baseProduct.discountPercent;

    return SliverAppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      expandedHeight: 440.0,
      pinned: true,
      automaticallyImplyLeading: false,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: context.backgroundColor.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: AppColors.cardShadow,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: context.backgroundColor.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow,
          ),
          child: IconButton(
            icon: Icon(Icons.share_outlined, color: context.textDark, size: 20),
            onPressed: () {},
          ),
        ),
        Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: context.backgroundColor.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow,
          ),
          child: BlocBuilder<WishlistBloc, WishlistState>(
            builder: (context, wishlistState) {
              final isWishlisted = _productDetails != null &&
                  wishlistState is WishlistLoaded &&
                  wishlistState.isWishlisted(_productDetails!.baseProduct.id);
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? context.accentColor : context.textDark,
                  size: 20,
                ),
                onPressed: () async {
                  if (_productDetails == null) return;
                  if (!await AuthGuard.requireLogin(context)) return;
                  if (!mounted) return;
                  context.read<WishlistBloc>().add(
                        WishlistToggleItemRequested(
                          productId: _productDetails!.baseProduct.id,
                        ),
                      );
                },
              );
            },
          ),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _productDetails!.imageGallery.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                  _selectedVariantIndex = index;
                });
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Hero(
                    tag: widget.heroTag ?? 'product_image_${_productDetails!.baseProduct.id}',
                    child:
                        _productDetails!.imageGallery[index].startsWith('http')
                            ? Image.network(
                                _productDetails!.imageGallery[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackProduct(context),
                              )
                            : Image.asset(
                                _productDetails!.imageGallery[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackProduct(context),
                              ),
                  );
                }
                return _productDetails!.imageGallery[index].startsWith('http')
                    ? Image.network(
                        _productDetails!.imageGallery[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            _buildFallbackProduct(context),
                      )
                    : Image.asset(
                        _productDetails!.imageGallery[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            _buildFallbackProduct(context),
                      );
              },
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.textDark.withValues(alpha: 0.26),
                      Colors.transparent,
                      Colors.transparent,
                      context.textDark.withValues(alpha: 0.45),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            // Discount Tag overlay
            if (hasDiscount && discountPct != null)
              Positioned(
                top: kToolbarHeight + 20,
                right: 16.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: context.accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'خصم $discountPct%',
                    style: TextStyle(
                      color: context.backgroundColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            // Horizontal Thumbnail strip overlay at bottom of image
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _productDetails!.imageGallery.length,
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
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _currentImageIndex == index
                              ? context.primaryColor
                              : context.backgroundColor.withValues(alpha: 0.6),
                          width: 2.w,
                        ),
                        boxShadow: _currentImageIndex == index
                            ? AppColors.tealGlowShadow
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _productDetails!.imageGallery[index]
                                .startsWith('http')
                            ? Image.network(
                                _productDetails!.imageGallery[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackProduct(context),
                              )
                            : Image.asset(
                                _productDetails!.imageGallery[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildFallbackProduct(context),
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

  Widget _buildHeaderInfo(BuildContext context) {
    final base = _productDetails!.baseProduct;
    final hasDiscount = base.originalPrice != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Name (clickable)
        GestureDetector(
          onTap: () {},
          child: Text(
            base.brand,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: context.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        // Product Name
        Text(
          base.name,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: context.textDark,
            height: 1.3.h,
          ),
        ),
        SizedBox(height: 10.h),
        // Stars Rating & Reviews Chevron link
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductReviewsPage(
                  reviews: _productDetails!.reviews,
                  ratingDistribution: _productDetails!.ratingDistribution,
                  averageRating: _productDetails!.baseProduct.rating,
                  totalReviews: _productDetails!.baseProduct.reviewCount,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(5, (i) {
                final full = i < base.rating.floor();
                return Icon(
                  full ? Icons.star_rounded : Icons.star_border_rounded,
                  color: context.primaryColor,
                  size: 16,
                );
              }),
              SizedBox(width: 6.w),
              Text(
                base.rating.toString(),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: context.textDark,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '·  ${base.reviewCount} تقييم',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.chevron_left, size: 16, color: context.textGrey),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        // Price Row with currency 'sar'.tr()
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${base.price.toInt()} ر.س',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
                color: hasDiscount ? context.accentColor : context.textDark,
              ),
            ),
            if (hasDiscount) ...[
              SizedBox(width: 10.w),
              Text(
                '${base.originalPrice!.toInt()} ر.س',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: context.textGrey,
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

  Widget _buildTamaraBanner(BuildContext context) {
    final installmentVal =
        (_productDetails!.baseProduct.price / 3).toStringAsFixed(2);
    return GestureDetector(
      onTap: _showTamaraSheet,
      child: Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.primaryColor, // Light peach Tamara tone
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.primaryColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'tamara'.tr(),
                style: TextStyle(
                  color: context.backgroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'قسّم فاتورتك على 3 دفعات بقيمة $installmentVal ر.س بدون فوائد. لمعرفة المزيد',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: context.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_back_ios,
                textDirection: ui.TextDirection.ltr,
                size: 12,
                color: context.textGrey),
          ],
        ),
      ),
    );
  }

  // ── Task 2: Image-driven variant picker (replaces color swatches) ───────────
  Widget _buildImageVariantPicker(BuildContext context) {
    final gallery = _productDetails!.imageGallery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'اختر اللون / التصميم',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                if (_productDetails!.imageGallery.length > 1) ...[                  
                  SizedBox(width: 4.w),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: (_triedToAdd && _selectedVariantIndex == null)
                          ? context.errorColor
                          : Colors.transparent,
                    ),
                    child: const Text('*'),
                  ),
                ],
              ],
            ),
            Text(
              '${_selectedVariantIndex != null ? _selectedVariantIndex! + 1 : 0} / ${gallery.length}',
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textGrey,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 68.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedVariantIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
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
                  margin: EdgeInsets.only(left: 12.w),
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? context.primaryColor : context.border,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: isSelected ? AppColors.tealGlowShadow : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: gallery[index].startsWith('http')
                        ? Image.network(
                            gallery[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildFallbackProduct(context),
                          )
                        : Image.asset(
                            gallery[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildFallbackProduct(context),
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

  Widget _buildSizePicker(BuildContext context) {
    final sizes = _productDetails!.availableSizes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'choose_size'.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: context.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(width: 4.w),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: (_triedToAdd && _selectedSizeIndex == null)
                    ? context.errorColor
                    : Colors.transparent,
              ),
              child: const Text('*'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.w,
          children: List.generate(sizes.length, (index) {
            final isSelected = _selectedSizeIndex == index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedSizeIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.primaryColor
                      : context.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? context.primaryColor : context.border,
                    width: 1.5.w,
                  ),
                  boxShadow: isSelected ? AppColors.tealGlowShadow : null,
                ),
                child: Text(
                  sizes[index],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color:
                        isSelected ? context.backgroundColor : context.textMid,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
  Widget _buildFallbackProduct(BuildContext context) {
    return Image.asset(
      'assets/images/fallback_product.png',
      fit: BoxFit.cover,
    );
  }


  Widget _buildDescription(BuildContext context) {
    final description = _productDetails!.description;
    final isLong = description.length > 180;
    final displayedText = isLong ? '${description.substring(0, 180)}...' : description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'product_details_and_specifications'.tr(),
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: context.textDark),
        ),
        SizedBox(height: 12.h),
        if (_productDetails!.sku != null) ...[
          Text(
            'رقم الصنف (SKU): ${_productDetails!.sku}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.textGrey,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        if (_productDetails!.tags.isNotEmpty) ...[
          Wrap(
            spacing: 6.w,
            runSpacing: 6.w,
            children: _productDetails!.tags
                .map((tag) => Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                            fontSize: 11.sp, color: context.primaryColor),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 12.h),
        ],
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Text(
              displayedText,
              style: TextStyle(
                fontSize: 13.sp,
                color: context.textMid,
                height: 1.8.h,
                fontFamily: 'Tajawal',
              ),
            ),
            if (isLong)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 30.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.surfaceColor.withValues(alpha: 0.0),
                        context.surfaceColor,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (isLong) ...[
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductSpecsPage(productDetails: _productDetails!),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'show_more_specifications'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12.sp, color: context.primaryColor),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewDistributionWidget(
          distribution: _productDetails!.ratingDistribution,
          averageRating: _productDetails!.baseProduct.rating,
          totalReviews: _productDetails!.baseProduct.reviewCount,
        ),
        SizedBox(height: 20.h),
        ..._productDetails!.reviews.map((r) => ReviewCardWidget(review: r)),
        SizedBox(height: 12.h),
        Center(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductReviewsPage(
                    reviews: _productDetails!.reviews,
                    ratingDistribution: _productDetails!.ratingDistribution,
                    averageRating: _productDetails!.baseProduct.rating,
                    totalReviews: _productDetails!.baseProduct.reviewCount,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.primaryColor, width: 1.5.w),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            ),
            child: Text(
              'show_all_reviews'.tr(),
              style: TextStyle(
                  color: context.primaryColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'similar_products'.tr(),
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: context.textDark),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductGridPage(
                      title: 'similar_products_1'.tr(),
                      filters: {
                        'category_id': _productDetails!.baseProduct.categoryId
                      },
                    ),
                  ),
                );
              },
              child: Text(
                'show_all'.tr(),
                style: TextStyle(
                    color: context.primaryColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ProductHorizontalRow(products: _productDetails!.similarProducts),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity Selector
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                border: Border.all(color: context.border, width: 1.5.w),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: context.textMid, size: 18),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    _quantity.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        color: context.textDark),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: context.textMid, size: 18),
                    onPressed: () {
                      setState(() => _quantity++);
                    },
                    constraints: const BoxConstraints(minWidth: 36),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            // Add to Cart Button (Namshe-style Gradient with Shopping Bag icon)
            Expanded(
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [context.primaryColor, context.primaryDark],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: AppColors.tealGlowShadow,
                ),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_productDetails == null) return;
                    if (!await AuthGuard.requireLogin(context)) return;
                    if (!mounted) return;

                    final sizes = _productDetails!.availableSizes.where((s) => s.trim().isNotEmpty).toList();
                    if (sizes.isNotEmpty && _selectedSizeIndex == null) {
                      setState(() => _triedToAdd = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('please_choose_the_size'.tr()),
                            backgroundColor: context.errorColor),
                      );
                      return;
                    }

                    // Require a variant selection when the product has >1 images.
                    final requiresVariantSelection = _productDetails!.imageGallery.length > 1;
                    if (requiresVariantSelection && _selectedVariantIndex == null) {
                      setState(() => _triedToAdd = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('please_choose_the_color'.tr()),
                            backgroundColor: context.errorColor),
                      );
                      return;
                    }

                    final imageId =
                        _currentImageIndex < _productDetails!.imageIds.length
                            ? _productDetails!.imageIds[_currentImageIndex]
                            : null;
                    String? sizeName = _selectedSizeIndex != null
                        ? sizes[_selectedSizeIndex!]
                        : null;
                    
                    if (sizeName == null || sizeName.trim().isEmpty) {
                      sizeName = '-'; // Fallback for products with no sizes so backend breakdown validation passes
                    }

                    HapticFeedback.mediumImpact();
                    context.read<CartBloc>().add(CartItemAdded(
                          productId: _productDetails!.baseProduct.id,
                          quantity: _quantity,
                          imageId: imageId,
                          sizeName: sizeName,
                        ));
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) => const AddToCartDialog(),
                    );
                  },
                  icon: Icon(Icons.shopping_bag_outlined,
                      color: context.backgroundColor, size: 20),
                  label: Text(
                    'add_to_cart'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                      color: context.backgroundColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

