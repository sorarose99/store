import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
          isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'سياسة الخصوصية والاستخدام' : 'Privacy & Usage Policy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic ? 'آخر تحديث: 15 يناير 2026' : 'Last Updated: January 15, 2026',
              style: TextStyle(fontSize: 11, color: context.textGrey),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              isArabic ? '1. المعلومات التي نقوم بجمعها لمتجرنا KDX' : '1. Information We Collect',
              isArabic
                  ? 'عند زيارتك أو تسجيلك أو طلبك من متجرنا KDX، قد نقوم بجمع المعلومات التالية:\nالاسم الكامل\nرقم الجوال\nعنوان البريد الإلكتروني\nعنوان الشحن والتوصيل\nمعلومات الدفع (لا نقوم بتخزين بيانات بطاقتك الائتمانية مباشرة، بل تمر من خلال بوابات دفع آمنة ومعتمدة)\nأي معلومات أخرى تختار تزويدنا بها طوعًا'
                  : 'When you visit, register, or order from KDX store, we may collect the following information:\nFull name\nMobile number\nEmail address\nShipping address\nPayment info (we do not store credit card details directly; they pass through secure gateways)\nAny other information you choose to provide voluntarily',
            ),
            _buildSection(
              context,
              isArabic ? '2. كيفية استخدام المعلومات' : '2. How We Use Information',
              isArabic
                  ? 'نستخدم بياناتك من أجل:\nمعالجة طلباتك وشحن المنتجات إليك\nتحسين خدماتنا وتجربة المستخدم\nالتواصل معك بخصوص الطلبات أو العروض أو التحديثات\nإدارة حسابك على الموقع (إن وجد)\nالامتثال للمتعلّقات القانونية والتنظيمية'
                  : 'We use your data to:\nProcess orders and ship products\nImprove our services and user experience\nCommunicate about orders, updates or offers\nManage your account on the site\nComply with legal and regulatory requirements',
            ),
            _buildSection(
              context,
              isArabic ? '3. حماية المعلومات' : '3. Protecting Information',
              isArabic
                  ? 'نستخدم مجموعة من الإجراءات الأمنية لحماية بياناتك من الوصول غير المصرح به أو التعديل أو الكشف أو الإتلاف، من خلال:\nبروتوكولات تشفير آمنة (SSL)\nمزودي خدمة دفع موثوقين\nإجراءات داخلية للحد من الوصول إلى البيانات'
                  : 'We use security measures to protect your data from unauthorized access, modification, or disclosure:\nSecure encryption protocols (SSL)\nTrusted payment providers\nInternal access restrictions',
            ),
            _buildSection(
              context,
              isArabic ? '4. استخدام رقم الجوال' : '4. Use of Mobile Number',
              isArabic
                  ? 'نستخدم رقم الجوال الخاص بالمستخدم لإرسال:\nرموز التحقق (OTP)\nإشعارات الطلبات\nتحديثات الشحن\nولا يتم استخدام الرقم لأغراض تسويقية بدون موافقة المستخدم.'
                  : 'We use your mobile number to send:\nVerification codes (OTP)\nOrder notifications\nShipping updates\nIt is not used for marketing without your consent.',
            ),
            _buildSection(
              context,
              isArabic ? '5. التعديلات على السياسة' : '5. Policy Updates',
              isArabic
                  ? 'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنقوم بنشر أي تغييرات على هذه الصفحة مع تحديث تاريخ آخر تعديل. نوصي بمراجعة هذه الصفحة بشكل دوري.'
                  : 'We may update this policy periodically. We will post any changes on this page with the updated date. We recommend checking this page regularly.',
            ),
            _buildSection(
              context,
              isArabic ? '6. اتصل بنا' : '6. Contact Us',
              isArabic
                  ? 'إذا كان لديك أي أسئلة حول سياسة الخصوصية، يرجى التواصل معنا:\n\n+966542139388\nSaudi Arabia'
                  : 'If you have any questions about this policy, please contact us:\n\n+966542139388\nSaudi Arabia',
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
