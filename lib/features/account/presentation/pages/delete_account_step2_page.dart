import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import 'delete_account_password_page.dart';

class DeleteAccountStep2Page extends StatelessWidget {
  const DeleteAccountStep2Page({super.key});

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
                      isArabic ? 'تقديم طلب لحذف الحساب' : 'Submit Account Deletion Request',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? 'لإتمام حذف حسابك، يجب تلبية الشروط التالية للتحقق من أمان حسابك.'
                          : 'To complete deletion of your account, the following security requirements must be met.',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textMid,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Warning Alert
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.errorColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.errorColor.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: context.errorColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'تنبيه: لن يكون الحساب قابلاً للاستعادة بمجرد حذفه'
                                  : 'Warning: The account cannot be recovered once deleted',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Check Cards
                    _buildCheckCard(
                      context,
                      icon: Icons.shield_outlined,
                      title: isArabic ? 'الحساب في حالة أمنة' : 'Account is Secure',
                      subtitle: isArabic ? 'الحساب غير معرض لأي مخاطر أمنية' : 'The account is not exposed to security risks',
                    ),
                    _buildCheckCard(
                      context,
                      icon: Icons.assignment_outlined,
                      title: isArabic ? 'طلبات الحساب مكتملة' : 'Account Orders are Complete',
                      subtitle: isArabic
                          ? 'لا توجد طلبات مسترجعة أو معلقة أو معاملات جارية في المتجر'
                          : 'No returns, pending orders, or ongoing transactions in the store',
                    ),
                    _buildCheckCard(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      title: isArabic ? 'رصيد المحفظة فارغ' : 'Wallet Balance is Empty',
                      subtitle: isArabic
                          ? 'يجب أن لا يكون هناك رصيد معلق أو مبالغ مالية متبقية في محفظتك'
                          : 'There must be no pending balance or remaining funds in your wallet',
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
                    backgroundColor: context.primaryColor,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Row(
        children: [
          // Icon wrapper
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.cardBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: context.textGrey,
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Passed checkmark
          Icon(
            Icons.check_circle_rounded,
            color: context.successColor,
            size: 22,
          ),
        ],
      ),
    );
  }
}
