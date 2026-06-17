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
                'شروط الاستخدام والأحكام العامة للمنصة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'تاريخ التحديث: 10 يونيو 2024',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              
              _buildSection(
                '1. شروط الاستخدام',
                'باستخدامك لهذه المنصة أو التطبيق، فإنك توافق بالكامل على الالتزام بكافة الشروط والأحكام المذكورة هنا. إذا كنت لا توافق على أي جزء من هذه الشروط، يرجى عدم استخدام المنصة أو إتمام أي عمليات شراء من خلالها.',
              ),
              _buildSection(
                '2. أحكام عامة',
                'يُحظر استخدام التطبيق لأي أغراض غير قانونية أو انتهاك حقوق الملكية أو التسبب في إلحاق الضرر بالبنية التحتية للمنصة. نحتفظ بالحق في تعليق أو إغلاق أي حساب يثبت مخالفته للأنظمة والتعليمات المنظمة للاستخدام.',
              ),
              _buildSection(
                '3. التزامات المستخدم',
                'يتحمل المستخدم المسؤولية الكاملة عن سرية بيانات حسابه وكلمة المرور الخاصة به، وكذلك عن جميع الأنشطة والعمليات التي تتم تحت حسابه. يجب تزويدنا بمعلومات صحيحة ودقيقة ومحدثة عند إتمام التسجيل أو تعبئة النماذج التجارية.',
              ),
              _buildSection(
                '4. سياسة الملكية الفكرية',
                'كافة المحتويات المتوفرة على المنصة بما في ذلك النصوص، التصاميم، الصور، الشعارات، الأيقونات، البرمجيات، وقواعد البيانات هي ملكية حصرية للمنصة ومحمية بموجب قوانين الملكية الفكرية وحقوق النشر ذات الصلة.',
              ),
              _buildSection(
                '5. القانون الحاكم',
                'تخضع هذه الشروط والأحكام وتُفسر وفقاً للأنظمة والقوانين السارية في المملكة العربية السعودية، وتختص المحاكم السعودية بالنظر في أي نزاع قد ينشأ عن استخدام المنصة.',
              ),
              _buildSection(
                '6. التحديث والتعديل',
                'نحتفظ بالحق في تحديث وتعديل شروط الاستخدام والأحكام في أي وقت ودون إشعار مسبق. يُنصح بمراجعة هذه الصفحة بشكل دوري لمعرفة أي تغييرات جديدة قد تطرأ عليها.',
              ),
              _buildSection(
                '7. الاتصال بنا',
                'إذا كان لديك أي استفسار أو تساؤل بخصوص الشروط والأحكام المذكورة أعلاه، يمكنك التواصل معنا مباشرة من خلال قنوات الدعم الفني المتوفرة في التطبيق أو عبر البريد الإلكتروني المخصص للدعم.',
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
