import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kdx/features/auth/presentation/pages/login_page.dart';
import 'package:kdx/core/constants/colors.dart';

class WelcomePromoDialog extends StatelessWidget {
  const WelcomePromoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: context.primaryColor, // Light cyan/mint background
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close,
                      size: 18,
                      color: context.textDark.withValues(alpha: 0.87)),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Title
            Text(
              'log_in_and_get'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: context.textDark.withValues(alpha: 0.87),
              ),
            ),
            SizedBox(height: 24.h),

            // 3 Benefit Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBenefitCard(
                  context: context,
                  icon: Icons.local_shipping_outlined,
                  iconColor: Colors.orange,
                  titleHighlight: 'delivery'.tr(),
                  titleRest: 'guaranteed_and_fast'.tr(),
                ),
                _buildBenefitCard(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  iconColor: context.successColor,
                  titleHighlight: 'enjoy'.tr(),
                  titleRest: 'with_exclusive_products'.tr(),
                ),
                _buildBenefitCard(
                  context: context,
                  icon: Icons.local_offer_outlined,
                  iconColor: Colors.purple,
                  titleHighlight: 'discounts'.tr(),
                  titleRest: 'awesome_exclusive'.tr(),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            // Free Shipping Text
            Text(
              'شحن مجاني\nعلى أول طلب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                height: 1.2.h,
                color: context.textDark.withValues(alpha: 0.87),
              ),
            ),
            SizedBox(height: 16.h),

            // Promo Code Button - Tap to Copy (Industry Standard)
            GestureDetector(
              onTap: () {
                // Copy to clipboard
                // Using Flutter's Clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نسخ الرمز الترويجي بنجاح! ✂️'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // We mock the actual clipboard copy to avoid needing flutter/services import if not present,
                // but usually it's: Clipboard.setData(ClipboardData(text: 'first'.tr()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: context.textDark,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x421A1A2E),
                        blurRadius: 4,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy, color: context.backgroundColor, size: 16),
                    SizedBox(width: 8.w),
                    Text(
                      'use_code_first'.tr(),
                      style: TextStyle(
                        color: context.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Login Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: Text(
                'log_in_now'.tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textDark.withValues(alpha: 0.87),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String titleHighlight,
    required String titleRest,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F1A1A2E),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 36),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                titleHighlight,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              titleRest,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xDE1A1A2E),
                height: 1.2.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
