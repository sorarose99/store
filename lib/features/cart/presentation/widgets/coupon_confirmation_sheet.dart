import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

class CouponConfirmationSheet extends StatelessWidget {
  final String couponCode;
  final double discountAmount;
  final VoidCallback onAccept;
  final VoidCallback onCancel;

  const CouponConfirmationSheet({
    super.key,
    required this.couponCode,
    required this.discountAmount,
    required this.onAccept,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top drag handle
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
            SizedBox(height: 24.h),

            // Coupon Icon with Glow
            Center(
              child: Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  size: 32,
                  color: context.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              'confirm_the_coupon_application'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 12.h),

            // Subtitle
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.textGrey,
                  fontFamily: 'Tajawal',
                  height: 1.4.h,
                ),
                children: [
                  TextSpan(text: 'would_you_like_to'.tr()),
                  TextSpan(
                    text: '"$couponCode"',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.textDark,
                    ),
                  ),
                  const TextSpan(text: '؟\n'),
                  TextSpan(text: 'you_will_get_an'.tr()),
                  TextSpan(
                    text: '${discountAmount.toStringAsFixed(1)} ﷼',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.primaryColor,
                    ),
                  ),
                  TextSpan(text: 'on_this_request'.tr()),
                ],
              ),
            ),
            SizedBox(height: 28.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () {
                        onAccept();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'accept_and_apply'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: context.backgroundColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 46.h,
                    child: OutlinedButton(
                      onPressed: () {
                        onCancel();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: context.textGreyLight, width: 1.5.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'cancel_the_code'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textGrey,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
