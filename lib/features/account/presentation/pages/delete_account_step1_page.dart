import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'delete_account_step2_page.dart';

class DeleteAccountStep1Page extends StatefulWidget {
  const DeleteAccountStep1Page({super.key});

  @override
  State<DeleteAccountStep1Page> createState() => _DeleteAccountStep1PageState();
}

class _DeleteAccountStep1PageState extends State<DeleteAccountStep1Page> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: context.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          isArabic ? 'حذف الحساب' : 'Delete Account',
          style: TextStyle(
            color: context.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'وصف عملية حذف حساب KDX' : 'KDX Account Deletion Policy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic
                          ? 'عزيزي عميل KDX، بمجرد حذف حسابك في أي وقت، ولن تعد معاملة عملية الحذف غير فعالة، لن تتمكن من استعادة بياناتك من حسابك، لذلك الرجاء قراءة البنود والتحذيرات التالية بعناية قبل البدء في عملية الحذف. يرجى فهم ما يلي:'
                          : 'Dear KDX customer, once your account is deleted, the process is permanent and cannot be undone. You will not be able to recover your account data. Please read the following terms carefully before proceeding:',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: context.textMid,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Section 1
                    Text(
                      isArabic ? '1. ماذا يعني حذف الحساب؟' : '1. What does account deletion mean?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      isArabic
                          ? 'سوف تفقد البيانات والمحتوى الموجود في حسابك، بما في ذلك سجلات التواصل والعمليات والرسوم.'
                          : 'You will lose all data and content in your account, including communication logs, transactions, and fees.',
                      context,
                    ),
                    _buildBulletPoint(
                      isArabic
                          ? 'لن تتمكن من استخدام حسابك لتسجيل الدخول إلى موقع KDX وتطبيقات الهاتف المحمول.'
                          : 'You will not be able to use your account to log into KDX website and mobile applications.',
                      context,
                    ),
                    const SizedBox(height: 20),

                    // Section 2
                    Text(
                      isArabic ? '2. عرض أو حفظ معلوماتك:' : '2. View or save your information:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      isArabic
                          ? 'ننصحك بحفظ المعلومات الموجودة في حسابك، وذلك حماية لك من فقدان هذه المعلومات للأبد.'
                          : 'We recommend saving the information in your account to prevent losing it forever.',
                      context,
                    ),
                    _buildBulletPoint(
                      isArabic
                          ? 'إذا لزم الأمر، يرجى حفظ نسخة احتياطية من المعلومات الموجودة في حسابك، في حال رغبت في استعادة حسابك في المستقبل.'
                          : 'If necessary, please backup your account information in case you wish to restore it in the future.',
                      context,
                    ),
                    const SizedBox(height: 20),

                    // Section 3
                    Text(
                      isArabic ? '3. قبل حذف حسابك، يرجى التأكد مما يلي:' : '3. Before deleting your account, ensure the following:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      isArabic
                          ? 'أن لا توجد طلبات غير مكتملة أو معلقة لم يتم شحنها أو تسليمها.'
                          : 'There are no incomplete or pending orders that have not been shipped or delivered.',
                      context,
                    ),
                    _buildBulletPoint(
                      isArabic ? 'أن لا يوجد رصيد معلق في محفظتك المادية.' : 'There is no remaining balance in your physical wallet.',
                      context,
                    ),
                    _buildBulletPoint(
                      isArabic ? 'أن لا توجد صفقات جارية في حسابك.' : 'There are no ongoing transactions on your account.',
                      context,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Section with Checkbox and Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Circular Checkbox
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _agreed ? context.primaryColor : context.textGrey,
                              width: 1.5,
                            ),
                            color: _agreed ? context.primaryColor : Colors.transparent,
                          ),
                          child: _agreed
                              ? const Icon(
                                  Icons.check,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isArabic ? 'الموافقة على وصف حذف حساب KDX' : 'I agree to KDX account deletion terms',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: context.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _agreed
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const DeleteAccountStep2Page(),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        disabledBackgroundColor: context.primaryColor.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isArabic ? 'متابعة' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: context.textGrey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: context.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
