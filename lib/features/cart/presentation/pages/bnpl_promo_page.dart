import 'package:kdx/core/constants/colors.dart';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BnplPromoPage extends StatelessWidget {
  final String provider; // 'tabby' or 'tamara'

  const BnplPromoPage({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isTabby = provider.toLowerCase() == 'tabby';
    final brandColor = isTabby ? context.primaryColor : context.primaryColor;
    final brandText = isTabby ? 'tabby'.tr() : 'tamara'.tr();
    final accentText = isTabby ? 't' : 'T';

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'الدفع عبر $brandText',
            style: TextStyle(
              color: context.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Hero Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: brandColor.withValues(alpha: 0.2), width: 1.w),
                ),
                child: Column(
                  children: [
                    // Brand Logo circle
                    Container(
                      width: 72.w,
                      height: 72.h,
                      decoration: BoxDecoration(
                        color: brandColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: brandColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        accentText,
                        style: TextStyle(
                          color: isTabby
                              ? context.textDark
                              : context.backgroundColor,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'تسوق الآن، وادفع لاحقاً مع $brandText',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      isTabby
                          ? 'split_your_bill_into'.tr()
                          : 'divide_your_bill_into'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: context.textGrey,
                        height: 1.4.h,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Benefits grid title
              Text(
                'لماذا تختار الدفع عبر $brandText؟',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 16.h),

              // Reusable Advantage cards
              _buildAdvantageCard(
                context,
                icon: Icons.percent_rounded,
                title: '0_interest_0_additional'.tr(),
                description: 'you_will_not_pay'.tr(),
                brandColor: brandColor,
              ),
              SizedBox(height: 12.h),
              _buildAdvantageCard(
                context,
                icon: Icons.flash_on_rounded,
                title: 'instant_and_easy_approval'.tr(),
                description: 'all_you_need_is'.tr(),
                brandColor: brandColor,
              ),
              SizedBox(height: 12.h),
              _buildAdvantageCard(
                context,
                icon: Icons.verified_user_outlined,
                title: 'completely_safe_and_reliable'.tr(),
                description: 'payments_are_100_secure'.tr(),
                brandColor: brandColor,
              ),
              SizedBox(height: 32.h),

              // How it works timeline title
              Text(
                'payment_method_in_simple'.tr(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 20.h),

              // Vertical Step rows
              _buildStepRow(
                  context, "1".tr(), 'add_your_favorite_products'.tr()),
              _buildStepRow(context, '2'.tr(),
                  'اختر $brandText كطريقة الدفع المفضلة لديك.'),
              _buildStepRow(context, '3'.tr(), 'enter_your_basic_data'.tr()),
              _buildStepRow(context, '4'.tr(),
                  isTabby ? 'pay_a_quarter_of'.tr() : 'pay_a_third_of'.tr()),

              SizedBox(height: 48.h),

              // CTA Button
              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'back_to_shopping'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.backgroundColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvantageCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color brandColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.primaryColor, width: 0.8.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: brandColor, size: 20),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.textGrey,
                    height: 1.4.h,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
      BuildContext context, String stepNumber, String instruction) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: context.textDark,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: context.backgroundColor,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
