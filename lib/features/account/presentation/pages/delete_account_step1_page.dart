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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textDark,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'حذف الحساب',
            style: TextStyle(
              color: AppColors.textDark,
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
                      const Text(
                        'وصف عملية حذف حساب KDX',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'عزيزي عميل KDX، بمجرد حذف حسابك في أي وقت، ولن تعد معاملة عملية الحذف غير فعالة، لن تتمكن من استعادة بياناتك من حسابك، لذلك الرجاء قراءة البنود والتحذيرات التالية بعناية قبل البدء في عملية الحذف. يرجى فهم ما يلي:',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Section 1
                      const Text(
                        '1. "ماذا يعني حذف الحساب؟"',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint('سوف تفقد البيانات والمحتوى الموجود في حسابك، بما في ذلك سجلات التواصل والعمليات والرسوم.'),
                      _buildBulletPoint('لن تتمكن من استخدام حسابك لتسجيل الدخول إلى (KDX) website and mobile applications.'),
                      const SizedBox(height: 20),

                      // Section 2
                      const Text(
                        '2. عرض أو حفظ معلوماتك:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint('ننصحك بحفظ المعلومات الموجودة في حسابك، وذلك حماية لك من فقدان هذه المعلومات للأبد.'),
                      _buildBulletPoint('إذا لزم الأمر، يرجى حفظ نسخة احتياطية من المعلومات الموجودة في حسابك، في حال رغبت في استعادة حسابك في المستقبل.'),
                      const SizedBox(height: 20),

                      // Section 3
                      const Text(
                        '3. قبل حذف حسابك، يرجى التأكد مما يلي:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint('أن لا توجد طلبات غير مكتملة أو معلقة لم يتم شحنها أو تسليمها.'),
                      _buildBulletPoint('أن لا يوجد رصيد معلق في محفظتك المادية.'),
                      _buildBulletPoint('أن لا توجد صفقات جارية في حسابك.'),
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
                                color: _agreed ? AppColors.primary : AppColors.textGrey,
                                width: 1.5,
                              ),
                              color: _agreed ? AppColors.primary : Colors.transparent,
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
                          const Expanded(
                            child: Text(
                              'الموافقة على وصف حذف حساب KDX',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
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
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'متابعة',
                          style: TextStyle(
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
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.textGrey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
