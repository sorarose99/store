import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdx/features/category/presentation/utils/category_image_resolver.dart';
import 'package:kdx/features/home/presentation/widgets/product_card.dart';
import 'package:kdx/features/product/presentation/pages/product_details_page.dart';
import '../../../../core/constants/colors.dart';
import '../blocs/home_bloc.dart';
import '../blocs/home_event.dart';
import '../blocs/home_state.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/section_header.dart';
import '../widgets/product_list_widgets.dart';
import '../../../../core/widgets/kdx_app_bar.dart';

import '../../../../core/widgets/home_premium_widgets.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../category/presentation/pages/category_navigation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeStarted());

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 20;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _showWelcomePopup();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (ctx, state) {
          if (state is HomeLoaded) _fadeController.forward(from: 0);
        },
        builder: (ctx, state) {
          return RefreshIndicator(
            color: context.primaryColor,
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeRefreshed());
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverSafeArea(
                  bottom: false,
                  sliver: _buildNamsheAppBar(context, _isScrolled, state),
                ),
                ..._buildBodySlivers(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNamsheAppBar(
      BuildContext context, bool innerBoxIsScrolled, HomeState state) {
    return KdxSliverAppBar(
      isScrolled: _isScrolled,
      bottomHeight: 0,
      bottom: null,
    );
  }

  Widget _buildCategoryText(BuildContext context, String text,
      {bool isActive = false}) {
    return Container(
      margin: EdgeInsets.only(left: 12.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isActive ? context.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? context.primaryColor : context.textGrey.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? context.backgroundColor : context.textDark,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          fontSize: 13.sp,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────
  List<Widget> _buildBodySlivers(HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return _buildShimmerSlivers();
    }
    if (state is HomeError) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: context.errorColor),
                SizedBox(height: 16.h),
                Text(state.message, style: TextStyle(color: context.textGrey)),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () =>
                      context.read<HomeBloc>().add(const HomeRefreshed()),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
        )
      ];
    }

    final loaded = state as HomeLoaded;
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: HomeBannerSlider(
            banners: loaded.banners,
          ),
        ),
      ),

      // Middle Banner removed as per user request

      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 24.h, bottom: 40.h),
          child: _buildFeaturedCollectionsGrid(context, loaded.categories),
        ),
      ),

      // ── Flash Sale ──────────────────────────────────────────────────
      if (loaded.flashSaleProducts.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: _buildFlashSaleBanner(context, loaded.flashSaleEndDate),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40.h),
            child: ProductHorizontalRow(
              heroTagPrefix: 'flash',
              products: loaded.flashSaleProducts,
            ),
          ),
        ),
      ],

      // ── Brands Row (Namshi Style) ──────────────────────────────────
      if (loaded.brands.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'brands_in_demand'.tr(),
            subtitle: '',
            actionLabel: 'show_all'.tr(),
            onAction: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => const CategoryNavigationPage(initialCategoryId: 'cat_all'),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40.h),
            child: _buildBrandsRow(context, loaded.brands),
          ),
        ),
      ],

      // ── Top Trends ────────────────────────────────────────────────
      if (loaded.trendingProducts.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'the_most_important_trends'.tr(),
            subtitle: '',
            actionLabel: 'show_all'.tr(),
            onAction: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => const CategoryNavigationPage(initialCategoryId: 'cat_all'),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40.h),
            child: ProductHorizontalRow(
              heroTagPrefix: 'trending',
              products: loaded.trendingProducts,
            ),
          ),
        ),
      ],

      // ── Namshi-Style Promo Block ──────────────────────────────────
      if (loaded.products.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 24.h, bottom: 24.h),
            child: _buildPromoBlock(context, loaded.products),
          ),
        ),

      // ── Most Selling ───────────────────────────────────────────
      SliverToBoxAdapter(
        child: SectionHeader(
          title: 'best_seller'.tr(),
          subtitle: '',
          actionLabel: 'show_all'.tr(),
          onAction: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const CategoryNavigationPage(initialCategoryId: 'cat_all'),
              ),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(bottom: 40.h),
          child: ProductHorizontalRow(
            heroTagPrefix: 'just_arrived',
            products: loaded.products,
          ),
        ),
      ),

      // ── Additional Products Bottom ─────────────────────────────
      SliverToBoxAdapter(
        child: SectionHeader(
          title: 'find_out_more'.tr(),
          subtitle: '',
          actionLabel: 'show_all'.tr(),
          onAction: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const CategoryNavigationPage(initialCategoryId: 'cat_all'),
              ),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: ProductGrid(
          products: loaded.products,
        ),
      ),

      SliverToBoxAdapter(child: SizedBox(height: 32.h)),
    ];
  }

  // ── Asymmetric Promotional Block ─────────────────────────────────────────────
  Widget _buildPromoBlock(BuildContext context, List<dynamic> products) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 350.h,
      color: context.primaryColor,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vertical Poster (Right side in RTL)
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 16.w, left: 8.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/home_banner_new.png', // Fallback or dynamic
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            context.textDark.withAlpha(150),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20.h,
                      right: 16.w,
                      left: 8.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'summer_collection'.tr(),
                            style: TextStyle(
                              color: context.backgroundColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.1.h,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'discover_whats_new'.tr(),
                            style: TextStyle(
                              color: context.backgroundColor,
                              fontSize: 12.sp,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Horizontal scrolling products (Left side in RTL)
          Expanded(
            flex: 3,
            child: ListView.separated(
               scrollDirection: Axis.horizontal,
               padding: EdgeInsets.only(left: 16.w),
               itemCount: products.length,
               separatorBuilder: (_, __) => SizedBox(width: 12.w),
               itemBuilder: (context, index) {
                 final product = products[index];
                 final heroTag = 'home_slider_product_image_${product.id}';
                 return SizedBox(
                   width: 180.w,
                   child: ProductCard(
                     product: product,
                     isWishlisted: false, // Wire with block later if needed
                     heroTag: heroTag,
                     onTap: () {
                       Navigator.of(context).push(
                         CupertinoPageRoute(
                           builder: (_) =>
                               ProductDetailsPage(
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
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleBanner(BuildContext context, DateTime? flashSaleEndDate) {
    // Determine the end of the day as a fallback for the dynamic countdown
    final now = DateTime.now();
    final fallbackTarget = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    final target = flashSaleEndDate ?? fallbackTarget;

    return FlashSaleCountdownBanner(
      target: target,
      onViewAll: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const CategoryNavigationPage(initialCategoryId: 'cat_all'),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCollectionsGrid(
      BuildContext context, List<dynamic> dynamicCategories) {
    // Take up to 8 categories to form a 4-column grid (2 rows)
    final categoriesToDisplay = dynamicCategories.take(8).toList();

    if (categoriesToDisplay.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.78,
          crossAxisSpacing: 10,
          mainAxisSpacing: 16,
        ),
        itemCount: categoriesToDisplay.length,
        itemBuilder: (context, index) {
          final item = categoriesToDisplay[index];

          return _ScalePressableCategory(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => CategoryNavigationPage(
                    initialCategoryId: item.id,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.primaryColor.withAlpha(50), width: 1.5.w),
                    ),
                    child: ClipOval(
                      child: _DynamicCategoryAvatar(
                        categoryId: item.id,
                        categoryName: item.name,
                        categorySlug: item.slug,
                        imageAsset: item.imageAsset,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Namshi Middle Banner ────────────────────────────────────────────────────
  Widget _buildNamshiMiddleBanner(String? imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const CategoryNavigationPage(initialCategoryId: 'cat_all'),
          ),
        );
      },
      child: Container(
        height: 220.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.textDark.withValues(alpha: 0.87), // Dark fallback
          image: DecorationImage(
            image: (imageUrl != null && imageUrl.startsWith('http'))
                ? CachedNetworkImageProvider(imageUrl)
                : const AssetImage('assets/images/home_banner_new.png')
                    as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                context.textDark.withAlpha(76), BlendMode.darken),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'your_style_this_summer'.tr(),
              style: TextStyle(
                color: context.backgroundColor,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'make_your_look_the'.tr(),
              style: TextStyle(
                color: context.backgroundColor,
                fontSize: 16.sp,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'shop_now'.tr(),
                style: TextStyle(
                  color: context.textDark,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Brands Row ──────────────────────────────────────────────────────────────
  Widget _buildBrandsRow(BuildContext context, List<dynamic> brands) {
    if (brands.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Column(
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    border: Border.all(color: context.border),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: brand.imageAsset != null &&
                            brand.imageAsset.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: brand.imageAsset,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) => Icon(
                                Icons.broken_image,
                                color: context.textGrey),
                          )
                        : Image.asset(
                            'assets/images/logo.png', // Or fallback brand
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  brand.name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Shimmer loading ──────────────────────────────────────────────────────────
  List<Widget> _buildShimmerSlivers() {
    return [
      // Story circles shimmer
      SliverToBoxAdapter(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: Column(
                      children: [
                        _ShimmerStaticBox(
                            height: 64.h, width: 64.w, radius: 32.w),
                        SizedBox(height: 5.h),
                        _ShimmerStaticBox(
                            height: 10.h, width: 48.w, radius: 4.w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: _ShimmerStaticBox(height: 240.h, radius: 18.w),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: List.generate(
                  5,
                  (i) => Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: _ShimmerStaticBox(
                        height: 36.h, width: 70.w, radius: 20.w),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, i) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: _ShimmerStaticBox(height: 280.h, radius: 14.w),
            ),
            childCount: 6,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.56,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
        ),
      ),
    ];
  }
}

class HomeCategoryFallbackImage extends StatefulWidget {
  final String categorySlug;
  final String categoryName;

  const HomeCategoryFallbackImage({
    super.key,
    required this.categorySlug,
    required this.categoryName,
  });

  @override
  State<HomeCategoryFallbackImage> createState() =>
      _HomeCategoryFallbackImageState();
}

class _HomeCategoryFallbackImageState extends State<HomeCategoryFallbackImage> {
  late ValueNotifier<String> _imageNotifier;

  @override
  void initState() {
    super.initState();
    _imageNotifier = CategoryImageResolver().resolveImage(
      slug: widget.categorySlug,
      name: widget.categoryName,
    );
  }

  @override
  void dispose() {
    _imageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _imageNotifier,
      builder: (context, imageUrl, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildImage(context, imageUrl),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context, String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        key: ValueKey(url),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    } else {
      return Image.asset(
        url,
        key: ValueKey(url),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }
  }

  Widget _buildFallback() {
    return Container(
      key: const ValueKey('error_fallback'),
      color: context.primaryColor,
      width: double.infinity,
      height: double.infinity,
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Static Box (used inside Shimmer.fromColors)
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerStaticBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const _ShimmerStaticBox({
    required this.height,
    this.width,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _DynamicCategoryAvatar extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final String categorySlug;
  final String imageAsset;

  const _DynamicCategoryAvatar({
    required this.categoryId,
    required this.categoryName,
    required this.categorySlug,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    if (imageAsset.isNotEmpty) {
      if (imageAsset.startsWith('assets/')) {
        return Image.asset(
          imageAsset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      }
      return CachedNetworkImage(
        imageUrl: imageAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return HomeCategoryFallbackImage(
      categorySlug: categorySlug,
      categoryName: categoryName,
    );
  }
}

/// A pressable widget that scales down with a spring bounce when tapped.
class _ScalePressableCategory extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScalePressableCategory({
    required this.child,
    required this.onTap,
  });

  @override
  State<_ScalePressableCategory> createState() =>
      _ScalePressableCategoryState();
}

class _ScalePressableCategoryState extends State<_ScalePressableCategory>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 350),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn,
          reverseCurve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();

  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: widget.child,
      ),
    );
  }
}
