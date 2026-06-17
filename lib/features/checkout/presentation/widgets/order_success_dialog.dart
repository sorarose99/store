import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green success circle with check
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF8DC63F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 20),

            const Text(
              'تم إتمام طلبك!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'رقم الطلب: $orderNumber',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 20),

            // Summary details
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _summaryRow('عدد المنتجات', '$itemCount منتج'),
                  const SizedBox(height: 8),
                  _summaryRow('الإجمالي', '$total ر.س', isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue shopping button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Pop dialog + all checkout pages back to main shell
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'مواصلة التسوق',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // View order button
            SizedBox(
              width: double.infinity,
              height: 48,
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
                  side: const BorderSide(color: Color(0xFFEEEEEE)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'عرض الطلب',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
