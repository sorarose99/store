import 'package:kdx/core/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../orders/presentation/pages/order_detail_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Order Success Dialog
// ─────────────────────────────────────────────────────────────────────────────

class OrderSuccessDialog extends StatelessWidget {
  final String orderNumber;
  final double total;
  final int itemCount;

  const OrderSuccessDialog({
    super.key,
    required this.orderNumber,
    required this.total,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: context.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green success circle with check
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: context.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded,
                  color: context.backgroundColor, size: 48),
            ),
            SizedBox(height: 20.h),

            Text(
              'your_order_has_been'.tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'رقم الطلب: $orderNumber',
              style: TextStyle(
                fontSize: 13.sp,
                color: context.textGrey,
              ),
            ),
            SizedBox(height: 20.h),

            // Summary details
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _summaryRow(
                      context, 'number_of_products'.tr(), '$itemCount منتج'),
                  SizedBox(height: 8.h),
                  _summaryRow(context, 'total_1'.tr(), '$total ر.س',
                      isHighlight: true),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Continue shopping button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  // Pop dialog + all checkout pages back to main shell
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'continue_shopping'.tr(),
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // View order button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailPage(orderNumber: orderNumber),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'view_the_order'.tr(),
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, String value,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textGrey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: isHighlight ? context.primaryColor : context.textDark,
          ),
        ),
      ],
    );
  }
}
