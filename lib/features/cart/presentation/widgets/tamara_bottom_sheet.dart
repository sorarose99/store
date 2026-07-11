import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

class TamaraBottomSheet extends StatelessWidget {
  final double installmentAmount;

  const TamaraBottomSheet({
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

            // Tamara Logo Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Tamara logo representation (orange circle with two dots)
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: context.primaryColor, // Tamara orange
                    shape: BoxShape.circle,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Container(
                        width: 4.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'tamara'.tr(),
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
              'قسم فاتورتك على 3 دفعات\nبقيمة $installmentAmount SAR بدون فوائد',
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

            // Steps vertical timeline (RTL: circles on the right, connecting line)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
              child: Column(
                children: [
                  _buildTimelineStep(
                    context,
                    icon: Icons.shopping_cart_outlined,
                    text: 'add_products_to_your'.tr(),
                    isFirst: true,
                  ),
                  _buildTimelineStep(
                    context,
                    icon: Icons.credit_card_rounded,
                    text: 'choose_tamara_at_checkout'.tr(),
                  ),
                  _buildTimelineStep(
                    context,
                    icon: Icons.badge_outlined,
                    text: 'add_your_data'.tr(),
                  ),
                  _buildTimelineStep(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    text: 'complete_your_first_payment'.tr(),
                    isLast: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
            Text(
              'أكمل دفعاتك المتبقية خلال شهرين | وفقاً لطريقة الدفع التي اخترتها',
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
              'why_choose_tamara_as'.tr(),
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
                _buildBenefitItem(context, Icons.card_giftcard_rounded,
                    'without_interest'.tr()),
                _buildBenefitItem(
                    context, Icons.money_off_rounded, 'no_fees'.tr()),
                _buildBenefitItem(
                    context, Icons.offline_bolt_outlined, 'easy_and_fast'.tr()),
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
          // Timeline indicator (Right side in RTL)
          Column(
            children: [
              // Circle avatar representing step
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: context.primaryColor, // Light peach background
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: context.primaryColor, // Tamara orange color
                ),
              ),
              // Connecting line
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
          // Step Text Description (Left side)
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
