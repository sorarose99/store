import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../category/presentation/pages/category_navigation_page.dart';
import '../../domain/entities/banner_entity.dart';
import '../../../../core/constants/colors.dart';

class HomeBannerSlider extends StatefulWidget {
  final List<BannerEntity> banners;

  const HomeBannerSlider({super.key, required this.banners});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  late List<dynamic> _mixedBanners;

  @override
  void initState() {
    super.initState();
    _mixedBanners = _buildMixedBanners();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(HomeBannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners != widget.banners) {
      _mixedBanners = _buildMixedBanners();
    }
  }

  List<dynamic> _buildMixedBanners() {
    // If API banners are available, use them exclusively
    if (widget.banners.isNotEmpty) {
      return widget.banners;
    }
    
    // Otherwise, fall back to static banners
    return [
      'assets/images/home_banner_new.png',
      'assets/images/banner_1.png',
      'assets/images/banner_2.png',
      'assets/images/banner_3.png',
      'assets/images/banner_4.png',
      'assets/images/banner_5.png',
      'assets/images/banner_6.png',
      'assets/images/banner_7.png',
    ];
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _mixedBanners.isEmpty) return;
      final next = (_currentIndex + 1) % _mixedBanners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_mixedBanners.length, (index) {
        final isSelected = _currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
          width: isSelected ? 20.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isSelected
                ? context.primaryColor
                : context.primaryColor.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_mixedBanners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _mixedBanners.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (ctx, i) {
              final item = _mixedBanners[i];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _MixedBannerCard(item: item),
              );
            },
          ),
        ),
        _buildIndicators(),
      ],
    );
  }
}

class _MixedBannerCard extends StatelessWidget {
  final dynamic item;

  const _MixedBannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isApiBanner = item is BannerEntity;
    final BannerEntity? banner = isApiBanner ? item as BannerEntity : null;
    final String staticPath = isApiBanner ? '' : item as String;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const CategoryNavigationPage(initialCategoryId: 'cat_all'),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: context.primaryColor,
          boxShadow: [
            BoxShadow(
              color: context.textDark.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            isApiBanner && banner!.image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: banner.image,
                    fit: BoxFit.fill,
                    errorWidget: (_, __, ___) =>
                        Image.asset('assets/images/banner_1.png', fit: BoxFit.fill),
                  )
                : Image.asset(
                    staticPath.isNotEmpty ? staticPath : 'assets/images/banner_1.png',
                    fit: BoxFit.fill,
                  ),
          ],
        ),
      ),
    );
  }
}
