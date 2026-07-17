import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
            'الشروط والأحكام',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الشروط والأحكام',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'آخر تحديث: 15 يناير 2026',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'مرحبًا بك في متجر KDX، باستخدامك لهذا الموقع أو إجراء عملية شراء، فإنك توافق على الالتزام بالشروط والأحكام التالية، يرجى قراءة هذه الشروط بعناية قبل استخدام الموقع.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textGrey, height: 1.6),
              ),
              const SizedBox(height: 24),

              _buildSection(
                '1. قبول الشروط',
                'باستخدامك لموقعنا KDX، فإنك تقر بأنك قرأت وفهمت ووافقت على الالتزام بهذه الشروط، سواء كنت مستخدمًا مسجلاً أم لا، في حال عدم موافقتك على هذه الشروط، يُرجى عدم استخدام الموقع.',
              ),
              _buildSection(
                '2. الحسابات',
                'قد يُطلب منك متجر KDX، إنشاء حساب للاستفادة من بعض خدمات الموقع.\nأنت مسؤول عن الحفاظ على سرية معلومات حسابك، بما في ذلك كلمة المرور.\nيحق لمتجرنا KDX، إيقاف أو إلغاء الحساب في حال اكتشاف أي استخدام غير قانوني أو خرق للشروط.',
              ),
              _buildSection(
                '3. المعلومات الشخصية',
                'تخضع جميع المعلومات التي تقدمها لسياسة الخصوصية الخاصة بنا متجر KDX.\nنحن متجر KDX نلتزم بحماية بياناتك وعدم مشاركتها مع أي طرف ثالث دون إذنك، إلا في حالات تنظيمية أو قانونية.',
              ),
              _buildSection(
                'اتصل بنا',
                'إذا كان لديك أي استفسار حول هذه الشروط، يرجى التواصل معنا:\n\n+966542139388\nSaudi Arabia',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
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
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
