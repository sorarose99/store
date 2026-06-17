import 'package:flutter/material.dart';
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
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle at top center
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Tamara Logo Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Tamara logo representation (orange circle with two dots)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFA670), // Tamara orange
                    shape: BoxShape.circle,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'تمارا',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Title Header
            Text(
              'قسم فاتورتك على 3 دفعات\nبقيمة $installmentAmount SAR بدون فوائد',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Tajawal',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Steps vertical timeline (RTL: circles on the right, connecting line)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  _buildTimelineStep(
                    icon: Icons.shopping_cart_outlined,
                    text: 'أضف المنتجات الى سلة التسوق',
                    isFirst: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.credit_card_rounded,
                    text: 'إختر تمارا عند الدفع',
                  ),
                  _buildTimelineStep(
                    icon: Icons.badge_outlined,
                    text: 'أضف بياناتك',
                  ),
                  _buildTimelineStep(
                    icon: Icons.account_balance_wallet_outlined,
                    text: 'أكمل دفعتك الأولى',
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'أكمل دفعاتك المتبقية خلال شهرين | وفقاً لطريقة الدفع التي اخترتها',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textGrey,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: AppColors.border, height: 40, thickness: 1),
            
            // Benefits list title
            const Text(
              'لماذا اختيار تمارا كوسيلة دفع؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 16),
            
            // Row of Benefits (Horizontal)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBenefitItem(Icons.card_giftcard_rounded, 'بدون فوائد'),
                _buildBenefitItem(Icons.money_off_rounded, 'بدون رسوم'),
                _buildBenefitItem(Icons.offline_bolt_outlined, 'سهلة وسريعة'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
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
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2EB), // Light peach background
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFFFFA670), // Tamara orange color
                ),
              ),
              // Connecting line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: const Color(0xFFFFA670).withValues(alpha: 0.3),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Step Text Description (Left side)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.textDark),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
