import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../blocs/shop_bloc.dart';
import '../blocs/shop_event.dart';
import '../blocs/shop_state.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../wishlist/presentation/blocs/wishlist_bloc.dart';
import '../../../wishlist/presentation/blocs/wishlist_event.dart';
import '../../../wishlist/presentation/blocs/wishlist_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../../domain/entities/filter_options_entity.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/kdx_app_bar.dart';
import '../../../search/presentation/pages/search_empty_page.dart';
import 'dart:ui';

class ProductGridPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> filters;

  const ProductGridPage({
    super.key,
    required this.title,
    this.filters = const {},
  });

  /// Backward-compatible constructor for category browsing.
  factory ProductGridPage.category({
    required String categoryName,
    required String categorySlug,
  }) {
    return ProductGridPage(
      title: categoryName,
      // Workaround for backend main category limitation: use text search
      filters: {'search': categoryName},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ShopBloc>()..add(ShopProductsRequested(filters: filters)),
      child: _ProductGridContentView(
        title: title,
        baseFilters: filters,
      ),
    );
  }
}

class _ProductGridContentView extends StatefulWidget {
  final String title;
  final Map<String, dynamic> baseFilters;

  const _ProductGridContentView({
    required this.title,
    required this.baseFilters,
  });

  @override
  State<_ProductGridContentView> createState() =>
      _ProductGridContentViewState();
}

class _ProductGridContentViewState extends State<_ProductGridContentView> {
  String _selectedSort = 'default'.tr();
  late Map<String, dynamic> _filters;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.baseFilters);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ShopBloc>().add(ShopProductsLoadMoreRequested(filters: _filters));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildQueryFilters({
    double? minPrice,
    double? maxPrice,
    List<String>? sizes,
    List<int>? ratings,
    String? sort,
  }) {
    final query = Map<String, dynamic>.from(widget.baseFilters);

    if (minPrice != null && minPrice > 0) query['min_price'] = minPrice;
    if (maxPrice != null && maxPrice < 1000) query['max_price'] = maxPrice;
    if (sizes != null && sizes.isNotEmpty) query['size_name'] = sizes.first;
    if (ratings != null && ratings.isNotEmpty) query['rating'] = ratings.first;
    if (sort != null && sort.isNotEmpty) query['sort'] = sort;

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: const KdxAppBar(),
        body: RefreshIndicator(
          color: context.primaryColor,
          onRefresh: () async {
            context
                .read<ShopBloc>()
                .add(ShopProductsRequested(filters: _filters));
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w900,
                      color: context.textDark,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                toolbarHeight: 56.h,
                titleSpacing: 0,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: context.backgroundColor.withOpacity(0.75),
                    ),
                  ),
                ),
                title: _buildSortAndFilterRow(context),
              ),
              BlocBuilder<ShopBloc, ShopState>(
                builder: (context, state) {
                  if (state is ShopLoading || state is ShopInitial) {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 24.h),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ProductCardShimmer(),
                          childCount: 6,
                        ),
                      ),
                    );
                  } else if (state is ShopError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: context.errorColor),
                            SizedBox(height: 16.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    color: context.textGrey),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () => context.read<ShopBloc>().add(
                                  ShopProductsRequested(filters: _filters)),
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is ShopLoaded) {
                    if (state.products.isEmpty) {
                      return SliverFillRemaining(
                        child: SearchEmptyPage(
                          failedQuery: _filters['search']?.toString(),
                          embedded: true,
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: EdgeInsets.all(12.w),
                      sliver: _buildProductSliverGrid(context, state.products),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
              BlocBuilder<ShopBloc, ShopState>(
                builder: (context, state) {
                  if (state is ShopLoaded && state.isFetchingMore) {
                    return SliverPadding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      sliver: const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildSortAndFilterRow(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Filter Button
              BlocBuilder<ShopBloc, ShopState>(builder: (context, state) {
                List<String> availableSizes = [];
                List<String> availableColors = [];
                if (state is ShopLoaded) {
                  if (state.sizes.isNotEmpty) {
                    availableSizes = state.sizes
                        .map((s) => s is Map ? s['name'].toString() : s.toString())
                        .toList();
                  }
                }

                return GestureDetector(
                  onTap: () async {
                    final shopBloc = context.read<ShopBloc>();
                    final result = await showModalBottomSheet<FilterOptionsEntity>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => FilterBottomSheet(
                        initialFilters: FilterOptionsEntity(
                          minPrice: double.tryParse(
                                  _filters['min_price']?.toString() ?? '0') ??
                              0,
                          maxPrice: double.tryParse(
                                  _filters['max_price']?.toString() ??
                                      '1000'.tr()) ??
                              1000,
                          selectedSizes: _filters['sizes']?.cast<String>() ?? [],
                        ),
                        availableSizes: availableSizes,
                        availableColors: availableColors,
                      ),
                    );
                    if (result != null) {
                      if (!mounted) return;
                      final filtersMap = _buildQueryFilters(
                        minPrice: result.minPrice,
                        maxPrice: result.maxPrice,
                        sizes: result.selectedSizes,
                        ratings: result.selectedRatings,
                      );
                      setState(() {
                        _filters = filtersMap;
                      });
                      shopBloc.add(ShopProductsRequested(filters: _filters));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tune, size: 18, color: context.primaryColor),
                        SizedBox(width: 6.w),
                        Text(
                          'filter_results'.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Sort Dropdown
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    if (value == 'price_asc') {
                      _selectedSort = 'price_from_low_to'.tr();
                    } else if (value == 'price_desc') {
                      _selectedSort = 'price_from_high_to'.tr();
                    } else {
                      _selectedSort = 'default'.tr();
                    }
                    _filters =
                        _buildQueryFilters(sort: value.isEmpty ? null : value);
                  });
                  context
                      .read<ShopBloc>()
                      .add(ShopProductsRequested(filters: _filters));
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                      value: '',
                      child: Text('default'.tr(),
                          style:
                              TextStyle(fontFamily: 'Tajawal', fontSize: 13.sp))),
                  PopupMenuItem(
                      value: 'price_asc',
                      child: Text('price_from_low_to'.tr(),
                          style:
                              TextStyle(fontFamily: 'Tajawal', fontSize: 13.sp))),
                  PopupMenuItem(
                      value: 'price_desc',
                      child: Text('price_from_high_to'.tr(),
                          style:
                              TextStyle(fontFamily: 'Tajawal', fontSize: 13.sp))),
                ],
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: context.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.borderColor, width: 1.w),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedSort,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: context.textDark,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.keyboard_arrow_down,
                          size: 16, color: context.textDark),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // U4: Result count row
          BlocBuilder<ShopBloc, ShopState>(
            builder: (context, state) {
              if (state is ShopLoaded && state.totalCount != null && state.totalCount! > 0) {
                return Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    'result_count'.tr(namedArgs: {'count': state.totalCount.toString()}),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.textGrey,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductSliverGrid(
      BuildContext context, List<ProductEntity> products) {
    // U5 fix: 2-column grid — more readable, standard in fashion apps.
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return CompactProductCard(
            product: product,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailsPage(slug: product.slug),
                ),
              );
            },
          );
        },
        childCount: products.length,
      ),
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasDiscount = product.originalPrice != null;

    return BlocBuilder<WishlistBloc, WishlistState>(
      builder: (context, wishlistState) {
        final isWishlisted = wishlistState is WishlistLoaded &&
            wishlistState.isWishlisted(product.id);

        return GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isHovered = true),
          onTapUp: (_) => setState(() => _isHovered = false),
          onTapCancel: () => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.identity()..scale(_isHovered ? 0.96 : 1.0),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.shadowColor.withOpacity(0.08),
                  blurRadius: _isHovered ? 4 : 12,
                  offset: Offset(0, _isHovered ? 2 : 6),
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
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 0.75,
                        child: product.imageAsset.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: product.imageAsset,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    _buildPlaceholder(),
                              )
                            : Image.asset(
                                product.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildPlaceholder(),
                              ),
                      ),
                    ),
                    // Gradient overlay to make heart pop and add depth
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.15),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: GestureDetector(
                        onTap: () async {
                          final wishlistBloc = context.read<WishlistBloc>();
                          if (!await AuthGuard.requireLogin(context)) return;
                          if (!mounted) return;
                          wishlistBloc.add(
                            WishlistToggleItemRequested(
                                productId: product.id),
                          );
                        },
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
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            color: isWishlisted
                                ? context.primaryColor
                                : context.textGrey,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Product info details — use Expanded to prevent overflow
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6.0.w, vertical: 6.0.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textDark,
                            fontFamily: 'Tajawal',
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 4.h),

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

                        SizedBox(height: 4.h),

                        // Price Tag
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${product.price.toInt()} ﷼',
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w900,
                                  color: context.primaryColor,
                                  fontFamily: 'Tajawal',
                                ),
                                overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  Widget _buildPlaceholder() {
    return Image.asset(
      'assets/images/fallback_product.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
