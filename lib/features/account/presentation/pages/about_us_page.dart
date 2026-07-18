import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: context.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isArabic ? 'من نحن' : 'About Us',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo/Graphics Container
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.storefront,
                    size: 48,
                    color: context.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Intro
            Text(
              isArabic ? 'مرحباً بك في متجرنا' : 'Welcome to Our Store',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isArabic
                  ? 'متجرنا هو وجهتك الأولى للحصول على أرقى الأزياء والمنتجات العصرية المصممة بعناية لتناسب أسلوب حياتك الفريد. نسعى لتقديم تجربة تسوق استثنائية وسهلة تجمع بين الجودة، التنوع، والأسعار المنافسة.'
                  : 'Our store is your premier destination for the finest fashion and trendy products carefully designed to fit your unique lifestyle. We strive to provide an exceptional and easy shopping experience combining quality, variety, and competitive prices.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: context.textGrey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Vision
            _buildValueCard(
              context,
              Icons.visibility_outlined,
              isArabic ? 'رؤيتنا' : 'Our Vision',
              isArabic
                  ? 'أن نصبح الخيار الأول والملهم لجميع عشاق الموضة والأناقة في المملكة ودول الخليج، من خلال دمج الإبداع بالتكنولوجيا الحديثة لتسهيل تجربة العميل.'
                  : 'To become the first and inspiring choice for all fashion and elegance lovers in the Kingdom and Gulf countries, by integrating creativity with modern technology to facilitate the customer experience.',
            ),
            const SizedBox(height: 16),

            // Mission
            _buildValueCard(
              context,
              Icons.rocket_launch_outlined,
              isArabic ? 'رسالتنا' : 'Our Mission',
              isArabic
                  ? 'توفير تشكيلات واسعة ومنتقاة بدقة من المنتجات العالية الجودة، مع التزامنا التام بتقديم خدمة عملاء استباقية وسريعة، وتوصيل آمن لجميع الشحنات.'
                  : 'Providing a wide and carefully selected assortment of high-quality products, with our full commitment to providing proactive and fast customer service, and safe delivery of all shipments.',
            ),
            const SizedBox(height: 16),

            // Values
            _buildValueCard(
              context,
              Icons.workspace_premium_outlined,
              isArabic ? 'قيمنا' : 'Our Values',
              isArabic
                  ? 'النزاهة والشفافية في التعامل، الالتزام بأعلى معايير الجودة، الاستدامة والمسؤولية الاجتماعية، والابتكار المستمر في خدماتنا ومنتجاتنا لتلبية وتجاوز توقعات عملائنا.'
                  : 'Integrity and transparency in dealing, commitment to the highest standards of quality, sustainability and social responsibility, and continuous innovation in our services and products to meet and exceed our customers’ expectations.',
            ),
            const SizedBox(height: 32),

            // Bottom details
            Divider(color: context.border),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'تواصل معنا' : 'Contact Us',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'البريد الإلكتروني: support@kdx-sa.com\nرقم الواتساب: +966542139388\nالمملكة العربية السعودية'
                  : 'Email: support@kdx-sa.com\nWhatsApp: +966542139388\nKingdom of Saudi Arabia',
              style: TextStyle(fontSize: 12, color: context.textGrey, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(BuildContext context, IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.cardBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
