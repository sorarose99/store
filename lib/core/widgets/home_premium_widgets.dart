import 'dart:async';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// 1. LIVE FLASH SALE COUNTDOWN BANNER
///    Pass a [target] DateTime and the banner counts down in real-time.
/// ─────────────────────────────────────────────────────────────────────────────
class FlashSaleCountdownBanner extends StatefulWidget {
  final DateTime target;
  final VoidCallback? onViewAll;

  const FlashSaleCountdownBanner({
    super.key,
    required this.target,
    this.onViewAll,
  });

  @override
  State<FlashSaleCountdownBanner> createState() =>
      _FlashSaleCountdownBannerState();
}

class _FlashSaleCountdownBannerState extends State<FlashSaleCountdownBanner> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.target.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = widget.target.difference(DateTime.now());
      if (mounted) {
        setState(() => _remaining = r.isNegative ? Duration.zero : r);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _pad(_remaining.inHours);
    final m = _pad(_remaining.inMinutes.remainder(60));
    final s = _pad(_remaining.inSeconds.remainder(60));

    // To make the layout fully language dynamic, we align content properly
    // without hardcoding 'end' alignments.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.primaryColor, context.primaryColor],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text('⚡', style: TextStyle(fontSize: 14.sp)),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'todays_sale'.tr(),
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w900,
                                fontSize: 14.sp,
                                color: context.backgroundColor,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'limited_exclusive_offers'.tr(),
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 10.sp,
                          color: const Color(0xCCFFFFFF),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Live countdown chips (LTR enforced to keep hour on left)
                Directionality(
                  textDirection: ui.TextDirection.ltr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CountdownUnit(value: h, label: 'time_h'.tr()),
                      const _Colon(),
                      _CountdownUnit(value: m, label: 'time_m'.tr()),
                      const _Colon(),
                      _CountdownUnit(value: s, label: 'time_s'.tr()),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Directionality.of(context) == ui.TextDirection.rtl
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: GestureDetector(
                onTap: widget.onViewAll,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: context.backgroundColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: context.backgroundColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'show_all'.tr(),
                    style: TextStyle(
                      color: context.backgroundColor,
                      fontSize: 12.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
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
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;
  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
                    .animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Text(
            value,
            key: ValueKey(value),
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w900,
              fontSize: 14.sp,
              color: context.backgroundColor,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 8.sp,
            color: const Color(0xBBFFFFFF),
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Text(
        ":",
        style: TextStyle(
          color: context.backgroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 2. TRENDING BRANDS HORIZONTAL STRIP
/// ─────────────────────────────────────────────────────────────────────────────
class TrendingBrandsStrip extends StatelessWidget {
  const TrendingBrandsStrip({super.key});

  List<({String name, String emoji, Color color})> _getBrands(
          BuildContext context) =>
      [
        (name: 'Nike', emoji: '👟', color: context.primaryColor),
        (name: 'Zara', emoji: '👗', color: context.primaryColor),
        (name: 'Adidas', emoji: '🏃', color: context.primaryColor),
        (name: 'H&M', emoji: '🛍️', color: context.primaryColor),
        (name: 'Aldo', emoji: '👠', color: context.primaryColor),
        (name: 'Mango', emoji: '🍊', color: context.primaryColor),
        (name: 'Guess', emoji: '💎', color: context.primaryColor),
        (name: 'Levi\'s', emoji: '👖', color: context.primaryColor),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  'show_all'.tr(),
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13.sp,
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'trending_brands'.tr(),
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w800,
                  fontSize: 17.sp,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 88.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: _getBrands(context).length,
            itemBuilder: (context, index) {
              final brand = _getBrands(context)[index];
              return _BrandChip(brand: brand);
            },
          ),
        ),
      ],
    );
  }
}

class _BrandChip extends StatefulWidget {
  final ({String name, String emoji, Color color}) brand;
  const _BrandChip({required this.brand});

  @override
  State<_BrandChip> createState() => _BrandChipState();
}

class _BrandChipState extends State<_BrandChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.primaryColor),
            boxShadow: [
              BoxShadow(
                color: context.textDark.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.brand.emoji, style: TextStyle(fontSize: 26.sp)),
              SizedBox(height: 4.h),
              Text(
                widget.brand.name,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 3. ANIMATED MARQUEE DEALS TICKER
/// ─────────────────────────────────────────────────────────────────────────────
class MarqueeDealsBanner extends StatefulWidget {
  const MarqueeDealsBanner({super.key});

  @override
  State<MarqueeDealsBanner> createState() => _MarqueeDealsBannerState();
}

class _MarqueeDealsBannerState extends State<MarqueeDealsBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const _text =
      '   ⚡ حتى 70% خصم على Nike   •   Zara خصومات حصرية   •   H&M آخر قطع   •   Adidas خصم 50%   •   اشتري 2 واحصل على 1 مجاناً   •   ';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: -1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.primaryColor, context.primaryColor],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return FractionalTranslation(
              translation: Offset(_animation.value, 0),
              child: child,
            );
          },
          child: Row(
            children: List.generate(
              3,
              (_) => Text(
                _text,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: context.backgroundColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
