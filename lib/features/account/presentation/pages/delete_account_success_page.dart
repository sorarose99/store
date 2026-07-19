import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';

class DeleteAccountSuccessPage extends StatelessWidget {
  const DeleteAccountSuccessPage({super.key});

  Future<void> _handleConfirm(BuildContext context) async {
    // Clear tokens globally so user is fully logged out after deleting account
    context.read<AuthBloc>().add(const LogoutRequested());

    // Clear onboarding preferences to simulate app reset
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', false);
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        automaticallyImplyLeading: false,
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Success Illustration / Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: context.primaryColor,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                isArabic ? 'تم تقديم الطلب بنجاح' : 'Request Submitted Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                isArabic
                    ? 'سيتم تعطيل حسابك مؤقتاً وسيتم حذفه نهائياً بعد مرور 30 يوماً. إذا رغبت في إلغاء طلب حذف حسابك، يمكنك تسجيل الدخول باستخدام بريدك الإلكتروني وكلمة المرور لإلغاء طلب الحذف.'
                    : 'Your account will be temporarily disabled and permanently deleted after 30 days. If you wish to cancel this request, you can log back in with your email and password to cancel.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: context.textMid,
                ),
              ),
              const Spacer(),
              
              // Confirm Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _handleConfirm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isArabic ? 'تأكيد' : 'Confirm',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
