import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../shell/presentation/pages/main_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class SuccessViewModel {
  final String title;
  final String subtitle;
  final String buttonLabel;

  const SuccessViewModel({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });

  static const registration = SuccessViewModel(
    title: 'تم التحقق',
    subtitle: 'تم التحقق من حسابك بنجاح\nيمكنك الآن تسجيل الدخول والتسوق',
    buttonLabel: 'الذهاب للرئيسية',
  );

  static const passwordReset = SuccessViewModel(
    title: 'تم التحقق',
    subtitle: 'تمت إعادة تعيين كلمة المرور بنجاح',
    buttonLabel: 'تسجيل الدخول',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class SuccessPage extends StatefulWidget {
  final bool isPasswordReset;

  const SuccessPage({super.key, this.isPasswordReset = false});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _checkFadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _checkFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    final vm = widget.isPasswordReset
        ? SuccessViewModel.passwordReset
        : SuccessViewModel.registration;

    if (vm.buttonLabel == 'الذهاب للرئيسية') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.isPasswordReset
        ? SuccessViewModel.passwordReset
        : SuccessViewModel.registration;

    return Scaffold(
      // Light grey background matches mockup device frame
      backgroundColor: const Color(0xFFEEEEF3),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Animated Checkmark Circle ──────────────────────────
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withAlpha(20),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2.5,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: _checkFadeAnim,
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      vm.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // ── Subtitle ────────────────────────────────────────────
                    Text(
                      vm.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // ── Done Button ─────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          vm.buttonLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
