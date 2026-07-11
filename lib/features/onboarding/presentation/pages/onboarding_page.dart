import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/onboarding_data.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _logoAnimController;

  @override
  void initState() {
    super.initState();
    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _logoAnimController.dispose();
    super.dispose();
  }

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
    if (_currentPage < onboardingSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == onboardingSlides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Page View ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // Slide PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingSlides.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, index) {
                        return _SlideCard(
                          slide: onboardingSlides[index],
                          index: index,
                        );
                      },
                    ),
                  ),

                  // ── Dots Indicator ────────────────────────────────────
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingSlides.length,
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

                  // ── Bottom Buttons ────────────────────────────────────
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
                                padding: EdgeInsets.symmetric(vertical: 14.h),
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

// ── Individual Slide Card ──────────────────────────────────────────────────
class _SlideCard extends StatelessWidget {
  final OnboardingSlide slide;
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
          // ── Image Card ──────────────────────────────────────────────────
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                  // Fashion photo
                  Image.asset(
                    slide.imagePath,
                    fit: BoxFit.cover,
                  ),
                ],
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
