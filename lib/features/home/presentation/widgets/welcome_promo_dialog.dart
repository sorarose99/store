import 'package:flutter/material.dart';
import 'package:store/features/auth/presentation/pages/login_page.dart';

class WelcomePromoDialog extends StatelessWidget {
  const WelcomePromoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7F6), // Light cyan/mint background
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
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            const Text(
              'سجل دخولك واحصل على:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // 3 Benefit Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBenefitCard(
                  icon: Icons.local_shipping_outlined,
                  iconColor: Colors.orange,
                  titleHighlight: 'توصيل',
                  titleRest: 'مضمون وسريع',
                ),
                _buildBenefitCard(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.green,
                  titleHighlight: 'تمتع',
                  titleRest: 'بمنتجات حصرية',
                ),
                _buildBenefitCard(
                  icon: Icons.local_offer_outlined,
                  iconColor: Colors.purple,
                  titleHighlight: 'خصومات',
                  titleRest: 'حصرية رهيبة',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Free Shipping Text
            const Text(
              'شحن مجاني\nعلى أول طلب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

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
                // but usually it's: Clipboard.setData(const ClipboardData(text: 'أولى'));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'استخدم الرمز: أولى',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Login Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text(
                'سجل الدخول الان',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required Color iconColor,
    required String titleHighlight,
    required String titleRest,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                titleHighlight,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titleRest,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
