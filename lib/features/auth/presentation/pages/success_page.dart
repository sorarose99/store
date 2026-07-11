import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../shell/presentation/pages/main_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class SuccessViewModel {
  final String title;
  final String subtitle;
  final String buttonLabel;

  SuccessViewModel({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });

  static final registration = SuccessViewModel(
    title: 'verified'.tr(),
    subtitle: 'تم التحقق من حسابك بنجاح\nيمكنك الآن تسجيل الدخول والتسوق',
    buttonLabel: 'go_to_the_main'.tr(),
  );

  static final passwordReset = SuccessViewModel(
    title: 'verified'.tr(),
    subtitle: 'the_password_has_been'.tr(),
    buttonLabel: 'login'.tr(),
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

    if (vm.buttonLabel == 'go_to_the_main'.tr()) {
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
      backgroundColor: context.primaryColor,
      body: Directionality(
        textDirection: Directionality.of(context),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0.w),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: context.textDark.withAlpha(18),
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
                        width: 96.w,
                        height: 96.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.primaryColor.withAlpha(20),
                          border: Border.all(
                            color: context.primaryColor,
                            width: 2.5.w,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: _checkFadeAnim,
                          child: Icon(
                            Icons.check_rounded,
                            color: context.primaryColor,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      vm.title,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: context.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),

                    // ── Subtitle ────────────────────────────────────────────
                    Text(
                      vm.subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: context.textGrey,
                        height: 1.6.h,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // ── Done Button ─────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _onDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          vm.buttonLabel,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: context.backgroundColor,
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
