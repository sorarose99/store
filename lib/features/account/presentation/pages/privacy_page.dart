import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
            'سياسة الخصوصية والاستخدام',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'سياسة الخصوصية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'آخر تحديث: 15 يناير 2026',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),

              _buildSection(
                '1. المعلومات التي نقوم بجمعها لمتجرنا KDX',
                'عند زيارتك أو تسجيلك أو طلبك من متجرنا KDX، قد نقوم بجمع المعلومات التالية:\nالاسم الكامل\nرقم الجوال\nعنوان البريد الإلكتروني\nعنوان الشحن والتوصيل\nمعلومات الدفع (لا نقوم بتخزين بيانات بطاقتك الائتمانية مباشرة، بل تمر من خلال بوابات دفع آمنة ومعتمدة)\nأي معلومات أخرى تختار تزويدنا بها طوعًا',
              ),
              _buildSection(
                '2. كيفية استخدام المعلومات',
                'نستخدم بياناتك من أجل:\nمعالجة طلباتك وشحن المنتجات إليك\nتحسين خدماتنا وتجربة المستخدم\nالتواصل معك بخصوص الطلبات أو العروض أو التحديثات\nإدارة حسابك على الموقع (إن وجد)\nالامتثال للمتطلبات القانونية والتنظيمية',
              ),
              _buildSection(
                '3. حماية المعلومات',
                'نستخدم مجموعة من الإجراءات الأمنية لحماية بياناتك من الوصول غير المصرح به أو التعديل أو الكشف أو الإتلاف، من خلال:\nبروتوكولات تشفير آمنة (SSL)\nمزودي خدمة دفع موثوقين\nإجراءات داخلية للحد من الوصول إلى البيانات',
              ),
              _buildSection(
                '4. استخدام رقم الجوال',
                'نستخدم رقم الجوال الخاص بالمستخدم لإرسال:\nرموز التحقق (OTP)\nإشعارات الطلبات\nتحديثات الشحن\nولا يتم استخدام الرقم لأغراض تسويقية بدون موافقة المستخدم.',
              ),
              _buildSection(
                '5. التعديلات على السياسة',
                'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنقوم بنشر أي تغييرات على هذه الصفحة مع تحديث تاريخ آخر تعديل. نوصي بمراجعة هذه الصفحة بشكل دوري.',
              ),
              _buildSection(
                '6. اتصل بنا',
                'إذا كان لديك أي أسئلة حول سياسة الخصوصية، يرجى التواصل معنا:\n\n+966542139388\nSaudi Arabia',
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
