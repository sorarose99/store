import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/token_service.dart';
import '../../../../core/constants/colors.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/ui_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../cart/presentation/pages/cart_filled_page.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
import '../../../cart/presentation/blocs/cart_state.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../blocs/wishlist_bloc.dart';
import '../blocs/wishlist_event.dart';
import '../blocs/wishlist_state.dart';
import 'wishlist_empty_page.dart';
import '../../../../core/widgets/app_shimmer.dart';

class WishlistFilledPage extends StatelessWidget {
  const WishlistFilledPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WishlistContentView();
  }
}

class _WishlistContentView extends StatefulWidget {
  const _WishlistContentView();

  @override
  State<_WishlistContentView> createState() => _WishlistContentViewState();
}

class _WishlistContentViewState extends State<_WishlistContentView> {
  bool _isGridView = true;
  String _searchQuery = '';
  bool _isSearchFocused = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _removeItem(BuildContext context, String id) {
    HapticFeedback.mediumImpact();
    context
        .read<WishlistBloc>()
        .add(WishlistToggleItemRequested(productId: id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, state) {
        if (state is WishlistLoading || state is WishlistInitial) {
          return Scaffold(
            backgroundColor: context.surfaceColor,
            body: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(bottom: 16.0.h),
                child: AppShimmer(
                    width: double.infinity, height: 100.h, borderRadius: 12),
              ),
            ),
          );
        } else if (state is WishlistError) {
          final isUnauthorized = state.message.contains('تسجيل') || 
                              state.message.contains('الجلسة') ||
                              state.message.contains('Unauthorized') ||
                              state.message.contains('401');
          if (isUnauthorized) {
            return Scaffold(
              backgroundColor: context.surfaceColor,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 80, color: context.primaryColor),
                      const SizedBox(height: 24),
                      Text(
                        'يرجى تسجيل الدخول لعرض قائمة الأمنيات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'قم بتسجيل الدخول لتتمكن من إضافة المنتجات المفضلة وعرض قائمتك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textGrey,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          final tokenService = di.sl<TokenService>();
                          await tokenService.clearAll();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: context.surfaceColor,
            body: Center(child: Text(state.message)),
          );
        } else if (state is WishlistLoaded) {
          final allItems = state.products;
          final wishlistItems = _searchQuery.isEmpty 
              ? allItems 
              : allItems.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          if (allItems.isEmpty) {
            return const WishlistEmptyPage();
          }

          return Directionality(
            textDirection: Directionality.of(context),
            child: Scaffold(
              backgroundColor: context.surfaceColor,
              appBar: AppBar(
                backgroundColor: context.surfaceColor.withValues(alpha: 0.8),
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: context.textDark, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerTitle: true,
                title: Text(
                  'wishlist'.tr(),
                  style: TextStyle(
                    color: context.textDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              body: Column(
                children: [
                  // Search & Action Row Below AppBar
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.0.w, vertical: 8.0.h),
                    child: Row(
                      children: [
                        // Grid/List toggle button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _isGridView = !_isGridView);
                          },
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: context.border, width: 0.8.w),
                            ),
                            child: Icon(
                              _isGridView
                                  ? Icons.view_list_rounded
                                  : Icons.grid_view_rounded,
                              color: context.textDark,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Search Input with glow-on-focus
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isSearchFocused
                                    ? context.primaryColor
                                    : context.border,
                                width: _isSearchFocused ? 1.5.w : 0.8.w,
                              ),
                              boxShadow: _isSearchFocused
                                  ? [
                                      BoxShadow(
                                        color: context.primaryColor
                                            .withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: _isSearchFocused
                                      ? context.primaryColor
                                      : context.textGrey,
                                  size: 18,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'search'.tr(),
                                      hintStyle: TextStyle(
                                        color: context.textGrey,
                                        fontSize: 13.sp,
                                        fontFamily: 'Tajawal',
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      color: context.textDark,
                                      fontSize: 13.sp,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _searchQuery = '';
                                        _searchController.clear();
                                      });
                                    },
                                    child: Icon(Icons.close_rounded,
                                        color: context.textGrey, size: 18),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Filter Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // Filter action
                          },
                          child: Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: context.cardBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: context.border, width: 0.8.w),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: context.textDark,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Shopping Bag Badge
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, cartState) {
                            int cartCount = 0;
                            if (cartState is CartLoaded) {
                              cartCount = cartState.items.length;
                            }
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const CartFilledPage()),
                                );
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color: context.primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      color: context.textDark,
                                      size: 20,
                                    ),
                                  ),
                                  if (cartCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: context.accentColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          cartCount.toString(),
                                          style: TextStyle(
                                            color: context.backgroundColor,
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Grid or List
                  Expanded(
                    child: RefreshIndicator(
                      color: context.primaryColor,
                      onRefresh: () async {
                        context
                            .read<WishlistBloc>()
                            .add(const WishlistRequested());
                      },
                      child: _isGridView
                          ? _buildGridView(context, wishlistItems)
                          : _buildListView(context, wishlistItems),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGridView(
      BuildContext context, List<ProductEntity> wishlistItems) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(12.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.48, // Compact layout for 3 columns
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
      ),
      itemCount: wishlistItems.length,
      itemBuilder: (context, index) {
        final product = wishlistItems[index];
        return CompactWishlistCard(
          product: product,
          onWishlistTap: () => _removeItem(context, product.id),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailsPage(slug: product.slug),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(
      BuildContext context, List<ProductEntity> wishlistItems) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: wishlistItems.length,
      itemBuilder: (context, index) {
        final product = wishlistItems[index];
        return Dismissible(
          key: Key('wishlist_item_${product.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            _removeItem(context, product.id);
          },
          background: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.red[400],
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailsPage(slug: product.slug),
                ),
              );
            },
            child: _HorizontalWishlistItemCard(
              product: product,
              onDelete: () => _removeItem(context, product.id),
              onAddToCart: () {
                context.read<CartBloc>().add(CartItemAdded(
                      productId: product.id,
                      quantity: 1,
                    ));
                KdxToast.showSuccess(context, 'تمت إضافة المنتج إلى السلة');
              },
            ),
          ),
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
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: context.textDark.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: context.border, width: 0.8.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Heart overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: AspectRatio(
                    aspectRatio: 0.76,
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: product.imageAsset.isNotEmpty
                          ? product.imageAsset.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: product.imageAsset,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    color: context.primaryColor,
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: context.textGrey,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  product.imageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: context.primaryColor,
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: context.textGrey,
                                      size: 24,
                                    ),
                                  ),
                                )
                          : Container(
                              color: context.primaryColor,
                              child: Icon(
                                Icons.image_outlined,
                                color: context.textGrey,
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6.h,
                  left: 6.w,
                  child: GestureDetector(
                    onTap: onWishlistTap,
                    child: Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: context.textDark.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: context.primaryColor,
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
                padding:
                    EdgeInsets.symmetric(horizontal: 6.0.w, vertical: 6.0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                        fontFamily: 'Tajawal',
                        height: 1.2.h,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: context.primaryColor,
                          size: 11,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: context.textGrey,
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
                          '${product.price.toInt()} ﷼',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w900,
                            color: context.primaryColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        if (hasDiscount) ...[
                          SizedBox(width: 4.w),
                          Text(
                            '${product.originalPrice!.toInt()}',
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              color: context.textGrey,
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
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: context.border, width: 1.w),
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
                child: Hero(
                  tag: 'product_image_${product.id}',
                  child: product.imageAsset.isNotEmpty
                      ? product.imageAsset.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: product.imageAsset,
                              width: 90.w,
                              height: 124.h,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 90.w,
                                height: 124.h,
                                color: context.cardBackground,
                                child: Icon(Icons.image_outlined,
                                    color: context.textGreyLight),
                              ),
                            )
                          : Image.asset(
                              product.imageAsset,
                              width: 90.w,
                              height: 124.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 90.w,
                                height: 124.h,
                                color: context.cardBackground,
                                child: Icon(Icons.image_outlined,
                                    color: context.textGreyLight),
                              ),
                            )
                      : Container(
                          width: 90.w,
                          height: 124.h,
                          color: context.cardBackground,
                          child: Icon(Icons.image_outlined,
                              color: context.textGreyLight),
                        ),
                ),
              ),
              if (hasDiscount && discountPct != null)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: context.accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$discountPct%−',
                      style: TextStyle(
                        color: context.backgroundColor,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),

          // Details Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Name
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: context.primaryColor,
                      letterSpacing: 0.5,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: context.textDark,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Rating Row
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: context.primaryColor, size: 14),
                      SizedBox(width: 2.w),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${product.reviewCount})',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: context.textGrey,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Price and Add to Cart Row
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Text(
                              '${product.originalPrice!.toInt()} ﷼',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: context.textGrey,
                                decoration: TextDecoration.lineThrough,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          Text(
                            '${product.price.toInt()} ﷼',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: hasDiscount
                                  ? context.accentColor
                                  : context.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Add to Cart Button (teal chip button)
                      ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: Icon(Icons.shopping_bag_outlined,
                            size: 12, color: context.backgroundColor),
                        label: Text(
                          'add_to_cart'.tr(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: context.backgroundColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          elevation: 0,
                          minimumSize: Size.zero,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 6.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Delete Action Floater
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.textGrey, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.all(12.w),
          ),
        ],
      ),
    );
  }
}
