import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
          isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'آخر تحديث: 15 يناير 2026' : 'Last Updated: January 15, 2026',
              style: TextStyle(fontSize: 11, color: context.textGrey),
            ),
            const SizedBox(height: 24),
            
            Text(
              isArabic
                  ? 'مرحبًا بك في متجر KDX، باستخدامك لهذا الموقع أو إجراء عملية شراء، فإنك توافق على الالتزام بالشروط والأحكام التالية، يرجى قراءة هذه الشروط بعناية قبل استخدام الموقع.'
                  : 'Welcome to KDX store. By using this website or making a purchase, you agree to comply with and be bound by the following terms and conditions. Please read these terms carefully before using the site.',
              style: TextStyle(fontSize: 12.5, color: context.textGrey, height: 1.6),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              isArabic ? '1. قبول الشروط' : '1. Acceptance of Terms',
              isArabic
                  ? 'باستخدامك لموقعنا KDX، فإنك تقر بأنك قرأت وفهمت ووافقت على الالتزام بهذه الشروط، سواء كنت مستخدمًا مسجلاً أم لا، في حال عدم موافقتك على هذه الشروط، يُرجى عدم استخدام الموقع.'
                  : 'By using our KDX website, you acknowledge that you have read, understood, and agreed to be bound by these terms, whether you are a registered user or not. If you do not agree to these terms, please do not use the website.',
            ),
            _buildSection(
              context,
              isArabic ? '2. الحسابات' : '2. Accounts',
              isArabic
                  ? 'قد يُطلب منك متجر KDX، إنشاء حساب للاستفادة من بعض خدمات الموقع.\nأنت مسؤول عن الحفاظ على سرية معلومات حسابك، بما في ذلك كلمة المرور.\nيحق لمتجرنا KDX، إيقاف أو إلغاء الحساب في حال اكتشاف أي استخدام غير قانوني أو خرق للشروط.'
                  : 'KDX store may require you to create an account to benefit from some services. You are responsible for maintaining the confidentiality of your account information, including your password. KDX reserves the right to suspend or cancel the account in case of illegal use or breach of terms.',
            ),
            _buildSection(
              context,
              isArabic ? '3. المعلومات الشخصية' : '3. Personal Information',
              isArabic
                  ? 'تخضع جميع المعلومات التي تقدمها لسياسة الخصوصية الخاصة بنا متجر KDX.\nنحن متجر KDX نلتزم بحماية بياناتك وعدم مشاركتها مع أي طرف ثالث دون إذنك، إلا في حالات تنظيمية أو قانونية.'
                  : 'All information you provide is subject to our KDX Privacy Policy. We are committed to protecting your data and not sharing it with any third party without your permission, except in regulatory or legal cases.',
            ),
            _buildSection(
              context,
              isArabic ? 'اتصل بنا' : 'Contact Us',
              isArabic
                  ? 'إذا كان لديك أي استفسار حول هذه الشروط، يرجى التواصل معنا:\n\n+966542139388\nSaudi Arabia'
                  : 'If you have any questions about these terms, please contact us:\n\n+966542139388\nSaudi Arabia',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
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
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              color: context.textGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
