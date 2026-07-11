import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../domain/entities/nav_category_entity.dart';
import '../../../cart/presentation/pages/cart_filled_page.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../blocs/category_bloc.dart';
import '../blocs/category_event.dart';
import '../blocs/category_state.dart';
import '../../../search/presentation/pages/search_active_page.dart';
import '../../../search_filter/presentation/pages/product_grid_page.dart';
import '../../../cart/presentation/blocs/cart_state.dart';
import '../utils/category_image_resolver.dart';

class CategoryNavigationPage extends StatelessWidget {
  final String? initialCategoryId;

  const CategoryNavigationPage({
    super.key,
    this.initialCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryBloc>()
        ..add(CategoryStarted(initialCategoryId: initialCategoryId)),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatefulWidget {
  const _CategoryView();

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView> {
  final ScrollController _sidebarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _sidebarScrollController.addListener(_onSidebarScroll);
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    super.dispose();
  }

  void _onSidebarScroll() {
    if (_sidebarScrollController.position.pixels >=
        _sidebarScrollController.position.maxScrollExtent - 50) {
      context
          .read<CategoryBloc>()
          .add(const CategoryLoadMoreMainCategoriesRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: _buildTopBar(context),
        ),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading || state is CategoryInitial) {
              return _buildLoadingShimmer(context);
            } else if (state is CategoryError) {
              return Center(
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
                            fontFamily: 'Tajawal', color: context.textGrey),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context
                          .read<CategoryBloc>()
                          .add(const CategoryStarted()),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            } else if (state is CategoryLoaded) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Right Sidebar: 25% width
                  _buildSidebar(context, state),
                  // Vertical Divider
                  Container(
                    width: 1.w,
                    color: context.border,
                  ),
                  // Left Content Grid: 75% width
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _buildGridContent(context, state),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              // Usually handled by the main shell, or navigates back if pushed
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child:
                Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
          ),
          SizedBox(width: 12.w),
          // Search Bar
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchActivePage()),
              ),
              child: Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: context.textGrey, size: 20),
                    SizedBox(width: 8.w),
                    Text(
                      'find_clothes'.tr(),
                      style: TextStyle(
                        color: context.textGrey,
                        fontSize: 13.sp,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Cart Icon
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartFilledPage()),
              );
            },
            icon: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        color: context.textDark, size: 24),
                    if (state is CartLoaded && state.items.isNotEmpty)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            state.items.length.toString(),
                            style: TextStyle(
                              color: context.backgroundColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, CategoryLoaded state) {
    final double sidebarWidth = MediaQuery.of(context).size.width * 0.26;
    return Container(
      width: sidebarWidth,
      color: context.primaryColor,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _sidebarScrollController,
              itemCount: state.mainCategories.length,
              itemBuilder: (context, index) {
                final cat = state.mainCategories[index];
                final isSelected = cat.id == state.selectedCategoryId;

                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      BlocProvider.of<CategoryBloc>(context)
                          .add(MainCategorySelected(cat.id));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: isSelected ? context.textDark : context.backgroundColor,
                    ),
                    child: Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? context.backgroundColor : context.textDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (state.isFetchingMoreMain)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(context.textDark),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGridContent(BuildContext context, CategoryLoaded state) {
    final selectedId = state.selectedCategoryId;
    final bool isLoadingSubcategories =
        !state.subCategories.containsKey(selectedId);
    final subcategories = state.subCategories[selectedId] ?? [];

    // Find active category
    MainCategoryEntity activeCat =
        const MainCategoryEntity(id: '', slug: '', name: '');
    for (final cat in state.mainCategories) {
      if (cat.id == selectedId) {
        activeCat = cat;
        break;
      }
    }

    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () async {
        context.read<CategoryBloc>().add(const CategoryStarted());
      },
      child: ListView(
        key: ValueKey<String>(selectedId),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(12.w),
        children: [
          // Header Title
          Text(
            activeCat.name,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: context.textDark,
            ),
          ),
          SizedBox(height: 16.h),

          // Subcategory Grid
          if (isLoadingSubcategories)
            _buildGridShimmer(context)
          else if (subcategories.isEmpty)
            _buildEmptyState(context)
          else
            _buildSubcategoryGrid(context, subcategories, activeCat),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSubcategoryGrid(BuildContext context,
      List<SubCategoryEntity> subcategories, MainCategoryEntity activeCat) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final sub = subcategories[index];
        return _CategoryTile(
          name: sub.name,
          imageUrl: sub.imageAsset,
          slug: sub.slug,
          mainCat: activeCat,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductGridPage.category(
                categoryName: sub.name,
                categorySlug: sub
                    .name, // Pass name instead of slug for backend compatibility
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Text(
          'there_are_no_subcategories'.tr(),
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14.sp,
            color: context.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Row(
      children: [
        // Sidebar shimmer
        Container(
          width: MediaQuery.of(context).size.width * 0.26,
          color: context.primaryColor,
          child: ListView.builder(
            itemCount: 6,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            itemBuilder: (_, __) => Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              child: AppShimmer(
                  width: double.infinity, height: 16.h, borderRadius: 4),
            ),
          ),
        ),
        Container(width: 1.w, color: context.border),
        // Grid content shimmer
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(
                    width: double.infinity, height: 120.h, borderRadius: 10),
                SizedBox(height: 16.h),
                AppShimmer(width: 120.w, height: 16.h, borderRadius: 4),
                SizedBox(height: 12.h),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, __) => Column(
                      children: [
                        const Expanded(
                          child: AppShimmer(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: 8),
                        ),
                        SizedBox(height: 6.h),
                        AppShimmer(width: 40.w, height: 10.h, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridShimmer(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Column(
        children: [
          const Expanded(
            child: AppShimmer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 8),
          ),
          SizedBox(height: 6.h),
          AppShimmer(width: 60.w, height: 12.h, borderRadius: 4),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  final String slug;
  final MainCategoryEntity mainCat;

  const _CategoryTile({
    required this.name,
    required this.imageUrl,
    required this.slug,
    required this.mainCat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: context.textDark,
              height: 1.2.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      }
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return DynamicCategoryFallbackImage(
      mainSlug: mainCat.slug,
      subSlug: slug,
      categoryName: name,
    );
  }
}

class DynamicCategoryFallbackImage extends StatefulWidget {
  final String mainSlug;
  final String subSlug;
  final String categoryName;

  const DynamicCategoryFallbackImage({
    super.key,
    required this.mainSlug,
    required this.subSlug,
    required this.categoryName,
  });

  @override
  State<DynamicCategoryFallbackImage> createState() =>
      _DynamicCategoryFallbackImageState();
}

class _DynamicCategoryFallbackImageState
    extends State<DynamicCategoryFallbackImage> {
  late ValueNotifier<String> _imageNotifier;

  @override
  void initState() {
    super.initState();
    _imageNotifier = CategoryImageResolver().resolveImage(
      slug: widget.subSlug,
      name: widget.categoryName,
      mainSlug: widget.mainSlug,
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
          child: _buildImage(imageUrl),
        );
      },
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return const AppShimmer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 8,
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        key: ValueKey(url),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _buildFallback(),
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
