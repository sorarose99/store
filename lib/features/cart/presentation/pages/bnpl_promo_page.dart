import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class BnplPromoPage extends StatelessWidget {
  final String provider; // 'tabby' or 'tamara'

  const BnplPromoPage({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final isTabby = provider.toLowerCase() == 'tabby';
    final brandColor = isTabby ? const Color(0xFF3DF2B6) : const Color(0xFFFFA670);
    final brandText = isTabby ? 'تابي' : 'تمارا';
    final accentText = isTabby ? 't' : 'T';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'الدفع عبر $brandText',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Hero Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                decoration: BoxDecoration(
                  color: brandColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: brandColor.withValues(alpha: 0.2), width: 1),
                ),
                child: Column(
                  children: [
                    // Brand Logo circle
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: brandColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: brandColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        accentText,
                        style: TextStyle(
                          color: isTabby ? Colors.black : Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'تسوق الآن، وادفع لاحقاً مع $brandText',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isTabby
                          ? 'قسم فاتورتك على 4 دفعات ميسرة بدون أي فوائد أو رسوم خفية!'
                          : 'قسم فاتورتك على 3 دفعات ميسرة بدون أي فوائد أو رسوم إضافية!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        height: 1.4,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Benefits grid title
              Text(
                'لماذا تختار الدفع عبر $brandText؟',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 16),

              // Reusable Advantage cards
              _buildAdvantageCard(
                icon: Icons.percent_rounded,
                title: '0% فوائد، 0% رسوم إضافية',
                description: 'لن تدفع أي ريال إضافي على قيمة طلبك طالما التزمت بالدفع في الموعد المحدد.',
                brandColor: brandColor,
              ),
              const SizedBox(height: 12),
              _buildAdvantageCard(
                icon: Icons.flash_on_rounded,
                title: 'موافقة فورية وسهلة',
                description: 'كل ما تحتاجه هو رقم الهوية ورقم الجوال والبطاقة البنكية لإكمال العملية في ثوانٍ.',
                brandColor: brandColor,
              ),
              const SizedBox(height: 12),
              _buildAdvantageCard(
                icon: Icons.verified_user_outlined,
                title: 'آمن وموثوق تماماً',
                description: 'عمليات دفع آمنة 100% ومشفرة بالكامل لحماية بياناتك الشخصية والبنكية.',
                brandColor: brandColor,
              ),
              const SizedBox(height: 32),

              // How it works timeline title
              const Text(
                'طريقة الدفع في خطوات بسيطة:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 20),

              // Vertical Step rows
              _buildStepRow('1', 'أضف منتجاتك المفضلة إلى السلة واذهب لصفحة الدفع.'),
              _buildStepRow('2', 'اختر $brandText كطريقة الدفع المفضلة لديك.'),
              _buildStepRow('3', 'أدخل بياناتك الأساسية (رقم الجوال ورقم الهوية).'),
              _buildStepRow('4', isTabby ? 'ادفع ربع القيمة كدفعة أولى وسدد الباقي على 3 أشهر.' : 'ادفع ثلث القيمة كدفعة أولى وسدد الباقي على شهرين.'),

              const SizedBox(height: 48),
              
              // CTA Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'العودة للتسوق',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvantageCard({
    required IconData icon,
    required String title,
    required String description,
    required Color brandColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECEEF5), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: brandColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    height: 1.4,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String stepNumber, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.textDark,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
