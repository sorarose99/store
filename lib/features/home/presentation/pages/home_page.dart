import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../blocs/home_bloc.dart';
import '../blocs/home_event.dart';
import '../blocs/home_state.dart';
import '../widgets/home_banner_slider.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/brand_spotlight_row.dart';
import '../widgets/product_list_widgets.dart';
import '../widgets/welcome_promo_dialog.dart';
import '../../../search/presentation/pages/search_active_page.dart';
import '../../../camera_search/presentation/pages/camera_search_page.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../cart/presentation/pages/cart_filled_page.dart';
import '../../../wishlist/presentation/pages/wishlist_filled_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String _selectedGender = 'نساء';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Mock story categories (replace with API data)
  final List<StoryCategoryItem> _storyCategories = const [
    StoryCategoryItem(
        label: 'الكل', imageAsset: 'assets/images/cat_all.png', isActive: true),
    StoryCategoryItem(
        label: 'فساتين', imageAsset: 'assets/images/cat_dresses.png'),
    StoryCategoryItem(
        label: 'أحذية', imageAsset: 'assets/images/cat_shoes.png'),
    StoryCategoryItem(label: 'حقائب', imageAsset: 'assets/images/cat_bags.png'),
    StoryCategoryItem(
        label: 'إكسسوار', imageAsset: 'assets/images/cat_accessories.png'),
    StoryCategoryItem(label: 'رياضة', imageAsset: 'assets/images/cat_sport.png'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeStarted());

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 20;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomePopup();
    });
  }

  void _showWelcomePopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => const WelcomePromoDialog(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<HomeBloc, HomeState>(
          listener: (ctx, state) {
            if (state is HomeLoaded) _fadeController.forward(from: 0);
          },
          builder: (ctx, state) {
            return NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
                _buildNamsheAppBar(innerBoxIsScrolled),
              ],
              body: _buildBody(state),
            );
          },
        ),
      ),
    );
  }

  // ── New Home Header ───────────────────────────────────────────────
  Widget _buildNamsheAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBBE5EC), Color(0xFFE8F8FA)],
          ),
          boxShadow: _isScrolled ? AppColors.elevatedShadow : null,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Wishlist | Search Bar | Notifications | Cart
              Row(
                children: [
                  // Wishlist
                  _buildIconWithBadge(
                    icon: Icons.favorite_border_rounded,
                    badgeCount: '1',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WishlistFilledPage()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search Bar
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchActivePage()),
                      ),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.search, color: AppColors.textDark, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'البحث...',
                                style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontFamily: 'Tajawal'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt_outlined, color: AppColors.textDark, size: 20),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const CameraSearchPage()),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification
                  _buildIconWithBadge(
                    icon: Icons.notifications_outlined,
                    badgeCount: '1',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsPage()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cart
                  _buildIconWithBadge(
                    icon: Icons.shopping_cart_outlined,
                    badgeCount: '1',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartFilledPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Row 2: Categories text row & Menu
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryText('الكل', isActive: true),
                          _buildCategoryText('نساء'),
                          _buildCategoryText('رجال'),
                          _buildCategoryText('اطفال'),
                          _buildCategoryText('حقائب'),
                          _buildCategoryText('اكسسوارات'),
                          _buildCategoryText('ملابس'),
                          _buildCategoryText('عروض كبرى'),
                          _buildCategoryText('أهم التريندات'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.menu, color: AppColors.textDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge({required IconData icon, required String badgeCount, required VoidCallback onTap}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: AppColors.textDark, size: 24),
        ),
        Positioned(
          top: -4,
          left: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Text(
              badgeCount,
              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryText(String text, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isActive ? AppColors.textDark : AppColors.textDark.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              fontFamily: 'Tajawal',
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 2,
              color: AppColors.textDark,
            ),
        ],
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────
  Widget _buildBody(HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return _buildShimmer();
    }
    if (state is HomeError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.message,
                style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(const HomeRefreshed()),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final loaded = state as HomeLoaded;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<HomeBloc>().add(const HomeRefreshed());
        },
        child: CustomScrollView(
          slivers: [
            // Hero banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: HomeBannerSlider(banners: loaded.banners),
              ),
            ),

            // Featured Collections Grid (2x4)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: _buildFeaturedCollectionsGrid(),
              ),
            ),

            // Story circles — relocated below banners
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: StoryCategoryRow(items: _storyCategories),
              ),
            ),

            // ── Flash Sale ──────────────────────────────────────────────────
            if (loaded.flashSaleProducts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildFlashSaleBanner(),
              ),
              SliverToBoxAdapter(
                child: ProductHorizontalRow(
                  products: loaded.flashSaleProducts,
                  onWishlistTap: (id) =>
                      context.read<HomeBloc>().add(WishlistToggled(id)),
                ),
              ),
            ],



            // ── Promo Banner ────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildPromoBanner()),

            // ── New Arrivals ────────────────────────────────────────────────
            if (loaded.trendingProducts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'وصل حديثاً',
                  subtitle: 'أحدث صيحات الموضة',
                  actionLabel: 'عرض الكل',
                  onAction: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: ProductHorizontalRow(
                  products: loaded.trendingProducts,
                  onWishlistTap: (id) =>
                      context.read<HomeBloc>().add(WishlistToggled(id)),
                ),
              ),
            ],

            // ── Main Product Grid ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'اكتشف المزيد',
                subtitle: 'منتجات مختارة لك',
                actionLabel: 'عرض الكل',
                onAction: () {},
              ),
            ),
            SliverToBoxAdapter(
              child: ProductGrid(
                products: loaded.products,
                onWishlistTap: (id) =>
                    context.read<HomeBloc>().add(WishlistToggled(id)),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ── Namshe Flash Sale Banner ─────────────────────────────────────────────────
  Widget _buildFlashSaleBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // "عرض الكل"
            GestureDetector(
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withAlpha(80), width: 1),
                ),
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Title + countdown
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _WhiteCountdownChip(value: '08', label: 'ث'),
                      const SizedBox(width: 3),
                      const Text(':',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 3),
                      _WhiteCountdownChip(value: '42', label: 'د'),
                      const SizedBox(width: 3),
                      const Text(':',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 3),
                      _WhiteCountdownChip(value: '03', label: 'س'),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تخفيضات اليوم ⚡',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'عروض حصرية محدودة',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xCCFFFFFF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCollectionsGrid() {
    final collections = [
      {'title': 'أحدث تشكيلة', 'img': 'assets/images/cat_latest.png'},
      {'title': 'فساتين', 'img': 'assets/images/cat_dresses.png'},
      {'title': 'شنط يد', 'img': 'assets/images/cat_bags.png'},
      {'title': 'بلايز وتيشيرتات', 'img': 'assets/images/cat_fashion.png'},
      {'title': 'سنيكرز', 'img': 'assets/images/cat_sports.png'},
      {'title': 'أحذية رياضة', 'img': 'assets/images/cat_sports.png'},
      {'title': 'أزياء عربية', 'img': 'assets/images/cat_fashion.png'},
      {'title': 'صنادل وأحذية فلات', 'img': 'assets/images/cat_fashion.png'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مجموعات مميزة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final item = collections[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchActivePage()),
                  );
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(item['img']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['title']!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Mid-page promo banner ────────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/banner_2.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A2E), AppColors.primaryDark],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xBB000000), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 18,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'اختيارنا لهذا الموسم',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'تسوقي الآن ←',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shimmer loading ──────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return CustomScrollView(
      slivers: [
        // Story circles shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    children: [
                      _ShimmerBox(height: 64, width: 64, radius: 32),
                      const SizedBox(height: 5),
                      _ShimmerBox(height: 10, width: 48, radius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _ShimmerBox(height: 240, radius: 18),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _ShimmerBox(height: 36, width: 70, radius: 20),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ShimmerBox(height: 280, radius: 14),
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
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Namshe Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class _NamsheSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onCameraTab;

  const _NamsheSearchBar(
      {required this.onTap, required this.onCameraTab});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'ابحثي عن ملابس، أحذية، حقائب...',
                style: TextStyle(
                  color: AppColors.textGreyLight,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 22,
              color: AppColors.border,
            ),
            GestureDetector(
              onTap: onCameraTab,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender Toggle
// ─────────────────────────────────────────────────────────────────────────────
class _GenderToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['نساء', 'رجال'].map((g) {
          final isActive = g == selected;
          return GestureDetector(
            onTap: () => onChanged(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                g,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textGrey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// White Countdown Chip (used in teal flash sale banner)
// ─────────────────────────────────────────────────────────────────────────────
class _WhiteCountdownChip extends StatelessWidget {
  final String value;
  final String label;
  const _WhiteCountdownChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withAlpha(60), width: 1),
      ),
      child: Text(
        '$value$label',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Box
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;

  const _ShimmerBox({
    required this.height,
    this.width,
    required this.radius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) => Container(
        height: widget.height,
        width: widget.width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFF8F8F8),
              Color(0xFFEEEEEE),
            ],
          ),
        ),
      ),
    );
  }
}
