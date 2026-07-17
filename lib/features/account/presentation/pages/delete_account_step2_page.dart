import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'delete_account_password_page.dart';

class DeleteAccountStep2Page extends StatelessWidget {
  const DeleteAccountStep2Page({super.key});

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
                        'تقديم طلب لحذف الحساب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'لإتمام حذف حسابك، يجب تلبية الشروط التالية للتحقق من أمان حسابك.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Warning Alert
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5), // Light red
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFE3E3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'تنبيه: لن يكون الحساب قابلاً للاستعادة بمجرد حذفه',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Check Cards
                      _buildCheckCard(
                        icon: Icons.shield_outlined,
                        title: 'الحساب في حالة أمنة',
                        subtitle: 'الحساب غير معرض لأي مخاطر أمنية',
                      ),
                      _buildCheckCard(
                        icon: Icons.assignment_outlined,
                        title: 'طلبات الحساب مكتملة',
                        subtitle: 'لا توجد طلبات مسترجعة أو معلقة أو معاملات جارية في المتجر',
                      ),
                      _buildCheckCard(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'يقصد بالإعلانات تلقي الأنشطة',
                        subtitle: 'يجب أن لا يكون هناك رصيد معلق أو مبالغ مالية متبقية في محفظتك',
                      ),
                    ],
                  ),
                ),
              ),

              // Action Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DeleteAccountPasswordPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon wrapper
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.textGrey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Content
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Passed checkmark
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 22,
          ),
        ],
      ),
    );
  }
}
