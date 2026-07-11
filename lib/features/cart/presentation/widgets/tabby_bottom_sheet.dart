import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

class TabbyBottomSheet extends StatelessWidget {
  final double installmentAmount;

  const TabbyBottomSheet({
    super.key,
    required this.installmentAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle at top center
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Tabby Logo Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Tabby logo representation (mint green circle with letter T)
                Container(
                  width: 26.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    color: context.primaryColor, // Tabby mint green
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    't',
                    style: TextStyle(
                      color: context.textDark,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'tabby'.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Title Header
            Text(
              'قسم فاتورتك على 4 دفعات\nبقيمة $installmentAmount SAR بدون فوائد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
                fontFamily: 'Tajawal',
                height: 1.4.h,
              ),
            ),
            SizedBox(height: 24.h),

            // Steps vertical timeline
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
              child: Column(
                children: [
                  _buildTimelineStep(
                    context,
                    icon: Icons.add_shopping_cart_rounded,
                    text: 'shop_and_approach_checkout'.tr(),
                    isFirst: true,
                  ),
                  _buildTimelineStep(
                    context,
                    icon: Icons.check_circle_outline_rounded,
                    text: 'choose_tabby_at_checkout'.tr(),
                  ),
                  _buildTimelineStep(
                    context,
                    icon: Icons.link_rounded,
                    text: 'link_your_bank_card'.tr(),
                  ),
                  _buildTimelineStep(
                    context,
                    icon: Icons.payments_outlined,
                    text: 'pay_the_down_payment'.tr(),
                    isLast: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
            Text(
              'أكمل دفعاتك المتبقية خلال 3 أشهر | بدون رسوم إضافية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: context.textGrey,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(color: context.border, height: 40.h, thickness: 1),

            // Benefits list title
            Text(
              'why_pay_via_tabby'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 16.h),

            // Row of Benefits (Horizontal)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBenefitItem(context, Icons.star_border_rounded,
                    'without_interest'.tr()),
                _buildBenefitItem(
                    context, Icons.verified_outlined, 'sharia_compliant'.tr()),
                _buildBenefitItem(
                    context, Icons.flash_on_outlined, 'easy_and_fast'.tr()),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required IconData icon,
    required String text,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: context.primaryColor, // Light mint background
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: context.primaryColor, // Tabby green
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5.w,
                    color: context.primaryColor.withValues(alpha: 0.3),
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          // Step Description
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8.0.h, bottom: 20.0.h),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: context.textDark),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: context.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
