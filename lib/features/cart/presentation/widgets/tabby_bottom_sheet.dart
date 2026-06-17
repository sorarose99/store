import 'package:flutter/material.dart';
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
            
            // Tabby Logo Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Tabby logo representation (mint green circle with letter T)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3DF2B6), // Tabby mint green
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    't',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'تابي',
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
              'قسم فاتورتك على 4 دفعات\nبقيمة $installmentAmount SAR بدون فوائد',
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
            
            // Steps vertical timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  _buildTimelineStep(
                    icon: Icons.add_shopping_cart_rounded,
                    text: 'تسوق واقترب من الدفع',
                    isFirst: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.check_circle_outline_rounded,
                    text: 'اختر تابي عند الدفع',
                  ),
                  _buildTimelineStep(
                    icon: Icons.link_rounded,
                    text: 'قم بربط بطاقتك البنكية',
                  ),
                  _buildTimelineStep(
                    icon: Icons.payments_outlined,
                    text: 'ادفع الدفعة الأولى والباقي لاحقاً',
                    isLast: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'أكمل دفعاتك المتبقية خلال 3 أشهر | بدون رسوم إضافية',
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
              'لماذا الدفع عبر تابي؟',
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
                _buildBenefitItem(Icons.star_border_rounded, 'بدون فوائد'),
                _buildBenefitItem(Icons.verified_outlined, 'متوافقة للشريعة'),
                _buildBenefitItem(Icons.flash_on_outlined, 'سهلة وسريعة'),
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
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8FAF4), // Light mint background
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFF1BE39A), // Tabby green
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: const Color(0xFF1BE39A).withValues(alpha: 0.3),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Step Description
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
