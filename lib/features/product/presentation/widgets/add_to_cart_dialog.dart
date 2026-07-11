import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../cart/presentation/pages/cart_filled_page.dart';

class AddToCartDialog extends StatelessWidget {
  const AddToCartDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: context.surfaceColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 32.0.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green Checkmark Circle
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: context.primaryColor, // Green brand color
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: context.backgroundColor,
                size: 48,
              ),
            ),
            SizedBox(height: 24.h),

            // Text Message
            Text(
              'the_product_has_been_1'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
              ),
            ),
            SizedBox(height: 32.h),

            // Continue Shopping Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'continue_shopping'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Go To Cart Button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Push to Cart Filled page as requested
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartFilledPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'go_to_basket'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.textDark,
                    fontWeight: FontWeight.bold,
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
