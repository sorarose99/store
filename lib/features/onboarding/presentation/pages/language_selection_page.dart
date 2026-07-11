import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/language_cubit.dart';
import 'onboarding_page.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  void _onLanguageSelected(BuildContext context, String langCode) async {
    if (langCode == 'ar') {
      await context.read<LanguageCubit>().setArabic();
      if (!context.mounted) return;
      await context.setLocale(const Locale('ar'));
    } else {
      await context.read<LanguageCubit>().setEnglish();
      if (!context.mounted) return;
      await context.setLocale(const Locale('en'));
    }

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine current language to know whether to force LTR or RTL for this screen
    // Actually, it's fine to just use the system or current locale.
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Graphic
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120.w,
                    height: 120.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 48.h),

              // Title
              Text(
                tr('select_language'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: context.textDark,
                ),
              ),
              SizedBox(height: 12.h),

              // Subtitle (Optional, but looks good)
              Text(
                'Please select your preferred language\nيرجى اختيار لغتك المفضلة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.textGrey,
                  height: 1.5.h,
                ),
              ),
              SizedBox(height: 48.h),

              // Arabic Option
              _LanguageOptionCard(
                title: 'arabic'.tr(),
                subtitle: 'Arabic',
                onTap: () => _onLanguageSelected(context, 'ar'),
              ),
              SizedBox(height: 16.h),

              // English Option
              _LanguageOptionCard(
                title: 'English',
                subtitle: 'english'.tr(),
                onTap: () => _onLanguageSelected(context, 'en'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LanguageOptionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: context.textDark.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: context.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.textGrey,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: context.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
