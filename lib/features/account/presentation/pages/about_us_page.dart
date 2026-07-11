import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'من نحن',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
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
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.storefront,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Intro
              const Text(
                'مرحباً بك في متجرنا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'متجرنا هو وجهتك الأولى للحصول على أرقى الأزياء والمنتجات العصرية المصممة بعناية لتناسب أسلوب حياتك الفريد. نسعى لتقديم تجربة تسوق استثنائية وسهلة تجمع بين الجودة، التنوع، والأسعار المنافسة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGrey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // Vision
              _buildValueCard(
                Icons.visibility_outlined,
                'رؤيتنا',
                'أن نصبح الخيار الأول والملهم لجميع عشاق الموضة والأناقة في المملكة ودول الخليج، من خلال دمج الإبداع بالتكنولوجيا الحديثة لتسهيل تجربة العميل.',
              ),
              const SizedBox(height: 16),

              // Mission
              _buildValueCard(
                Icons.rocket_launch_outlined,
                'رسالتنا',
                'توفير تشكيلات واسعة ومنتقاة بدقة من المنتجات العالية الجودة، مع التزامنا التام بتقديم خدمة عملاء استباقية وسريعة، وتوصيل آمن لجميع الشحنات.',
              ),
              const SizedBox(height: 16),

              // Values
              _buildValueCard(
                Icons.workspace_premium_outlined,
                'قيمنا',
                'النزاهة والشفافية في التعامل، الالتزام بأعلى معايير الجودة، الاستدامة والمسؤولية الاجتماعية، والابتكار المستمر في خدماتنا ومنتجاتنا لتلبية وتجاوز توقعات عملائنا.',
              ),
              const SizedBox(height: 32),

              // Bottom details
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),
              const Text(
                'تواصل معنا',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'البريد الإلكتروني: contact@store.com\nالرقم الموحد: 920002244\nالرياض، المملكة العربية السعودية',
                style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.5),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
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
