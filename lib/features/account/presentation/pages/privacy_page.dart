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
                'بيان سياسة الخصوصية وسرية المعلومات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'تاريخ التحديث: 10 يونيو 2024',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),

              _buildSection(
                '1. جمع المعلومات',
                'نقوم بجمع بعض البيانات اللازمة لتقديم أفضل تجربة تسوق لك، مثل: الاسم، رقم الجوال، البريد الإلكتروني، وعنوان التوصيل. كما نجمع معلومات لوجستية وإحصائية متعلقة بالزيارات وتفضيلات المنتجات بشكل آمن وتلقائي.',
              ),
              _buildSection(
                '2. استخدام المعلومات',
                'تُستخدم البيانات التي نجمعها بشكل أساسي لمعالجة طلبات الشراء والشحن، والتواصل معك بشأن تحديثات الشحنات، بالإضافة إلى تحسين جودة خدماتنا وتقديم عروض تسويقية مخصصة تناسب رغباتك وتفضيلاتك.',
              ),
              _buildSection(
                '3. حماية المعلومات',
                'نلتزم بأعلى معايير الأمن السيبراني لحماية بياناتك من الوصول غير المصرح به أو التعديل أو الإفشاء. يتم استخدام تقنيات التشفير المتقدمة وبروتوكولات الأمان الإلكترونية لحماية العمليات المالية والبيانات الشخصية.',
              ),
              _buildSection(
                '4. ملفات تعريف الارتباط (Cookies)',
                'يستخدم التطبيق والمنصة ملفات تعريف الارتباط لتحسين أداء التصفح وتذكر المنتجات المضافة للسلة، بالإضافة إلى توفير إحصائيات تساعدنا على تحسين تجربة التسوق والتصفح بشكل مستمر.',
              ),
              _buildSection(
                '5. مشاركة المعلومات مع أطراف ثالثة',
                'لا نقوم ببيع أو تأجير بياناتك الشخصية لأي جهة خارجية. تتم مشاركة بعض المعلومات الضرورية فقط مع شركائنا الموثوقين لغرض إتمام الخدمة (مثل مشاركة عنوانك ورقم جوالك مع شركات الشحن والتوصيل).',
              ),
              _buildSection(
                '6. حقوق المستخدم',
                'يحق لك في أي وقت مراجعة بياناتك المسجلة لدينا وتحديثها أو تصحيحها، كما يمكنك طلب حذف حسابك وبياناتك الشخصية بشكل نهائي من خلال خيار "حذف الحساب" المتاح في إعدادات التطبيق.',
              ),
              _buildSection(
                '7. التغييرات على سياسة الخصوصية',
                'قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر لتعكس التغييرات في ممارساتنا أو لأسباب تشغيلية وقانونية أخرى. سيتم نشر النسخة المحدثة وتحديث تاريخ العمل بها على الفور في هذه الصفحة.',
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
