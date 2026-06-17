import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_text_field.dart';
import 'success_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class ResetPasswordData {
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordData({
    required this.newPassword,
    required this.confirmPassword,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class ResetPasswordPage extends StatefulWidget {
  final String phoneNumber;

  const ResetPasswordPage({super.key, required this.phoneNumber});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ResetPasswordSubmitted(
              phoneNumber: widget.phoneNumber,
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const SuccessPage(isPasswordReset: true),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // ── Key Icon ───────────────────────────────────────────
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.vpn_key_outlined,
                            color: AppColors.primary,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Title ──────────────────────────────────────────────
                      const Center(
                        child: Text(
                          'إعادة تعيين كلمة المرور',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'أدخل كلمة المرور الجديدة\nلتتمكن من الوصول إلى حسابك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── New Password ───────────────────────────────────────
                      const _FieldLabel(text: 'كلمة المرور الجديدة'),
                      const SizedBox(height: 6),
                      AuthTextField(
                        controller: _newPasswordController,
                        hintText: 'أدخل كلمة المرور الجديدة',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'يرجى إدخال كلمة المرور الجديدة';
                          }
                          if (v.length < 6) {
                            return 'يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Confirm Password ───────────────────────────────────
                      const _FieldLabel(text: 'تأكيد كلمة المرور'),
                      const SizedBox(height: 6),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        hintText: 'أعد كتابة كلمة المرور',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'يرجى تأكيد كلمة المرور';
                          }
                          if (v != _newPasswordController.text) {
                            return 'كلمات المرور غير متطابقة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),

                      // ── Submit Button ──────────────────────────────────────
                      if (state is AuthLoading)
                        const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        )
                      else
                        ElevatedButton(
                          onPressed: _onResetPressed,
                          child:
                              const Text('حفظ كلمة المرور الجديدة'),
                        ),
                      const SizedBox(height: 20),

                      // ── Back to Login ──────────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.popUntil(context, (r) => r.isFirst),
                          child: const Text(
                            'العودة لتسجيل الدخول',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}
