import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/pages/login_page.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Always use static asset slides — API is never called in onboarding.
  static const List<_StaticSlide> _slides = [
    _StaticSlide(assetPath: 'assets/images/onboarding_1.png'),
    _StaticSlide(assetPath: 'assets/images/onboarding_2.png'),
    _StaticSlide(assetPath: 'assets/images/onboarding_3.png'),
    _StaticSlide(assetPath: 'assets/images/onboarding_4.png'),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLast = _slides.isNotEmpty && _currentPage == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Page View ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Slide PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (i) {
                        setState(() => _currentPage = i);
                      },
                      itemBuilder: (context, index) {
                        return _SlideCard(
                          slide: _slides[index],
                          index: index,
                        );
                      },
                    ),
                  ),

                  // ── Dots Indicator ─────────────────────────────────────────
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == i ? 22 : 8,
                        height: 8.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == i
                              ? context.primaryColor
                              : context.border,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ── Bottom Buttons ─────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        // Skip (shown only on non-last slides)
                        if (!isLast)
                          Expanded(
                            child: TextButton(
                              onPressed: _completeOnboarding,
                              style: TextButton.styleFrom(
                                foregroundColor: context.textGrey,
                                padding:
                                    EdgeInsets.symmetric(vertical: 14.h),
                              ),
                              child: Text(
                                tr('skip'),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (!isLast) SizedBox(width: 12.w),

                        // Continue / Start
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            child: Text(isLast
                                ? tr('get_started')
                                : tr('continue_btn')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Simple static slide model (asset-only) ────────────────────────────────────

class _StaticSlide {
  final String assetPath;
  const _StaticSlide({required this.assetPath});
}

// ── Individual Slide Card ─────────────────────────────────────────────────────

class _SlideCard extends StatelessWidget {
  final _StaticSlide slide;
  final int index;

  const _SlideCard({
    required this.slide,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image Card ───────────────────────────────────────────────────
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: context.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: context.textDark.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              // alignment: centerLeft ensures the KDX logo on the left
              // edge is always fully visible and never cropped.
              child: Image.asset(
                slide.assetPath,
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Title ────────────────────────────────────────────────────────
          Text(
            tr('onboarding_title_${index + 1}'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: context.textDark,
              height: 1.4.h,
            ),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),

          // ── Description ──────────────────────────────────────────────────
          Text(
            tr('onboarding_desc_${index + 1}'),
            style: TextStyle(
              fontSize: 13.sp,
              color: context.textGrey,
              height: 1.55.h,
            ),
            textAlign: TextAlign.start,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
