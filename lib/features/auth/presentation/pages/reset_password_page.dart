import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../../../../core/utils/error_handler.dart';
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

  ResetPasswordData({
    required this.newPassword,
    required this.confirmPassword,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordPage(
      {super.key, required this.email, required this.otpCode});

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
              email: widget.email,
              otpCode: widget.otpCode,
              newPassword: _newPasswordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
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
            showCustomSnackBar(context, getLocalizedError(state.message));
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: Directionality.of(context),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20.h),

                      // ── Icon ───────────────────────────────────────────────
                      Center(
                        child: Container(
                          width: 72.w,
                          height: 72.h,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.vpn_key_outlined,
                            color: colorScheme.primary,
                            size: 34,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Title ──────────────────────────────────────────────
                      Center(
                        child: Text(
                          'reset_password'.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Center(
                        child: Text(
                          'أدخل كلمة المرور الجديدة\nلتتمكن من الوصول إلى حسابك',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 36.h),

                      // ── New Password ───────────────────────────────────────
                      _FieldLabel(text: 'new_password'.tr()),
                      SizedBox(height: 6.h),
                      AuthTextField(
                        controller: _newPasswordController,
                        hintText: 'enter_the_new_password'.tr(),
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return tr('validation_new_password_required');
                          }
                          if (v.length < 6) {
                            return tr('validation_password_min_length');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // ── Confirm Password ───────────────────────────────────
                      _FieldLabel(text: tr('confirm_password')),
                      SizedBox(height: 6.h),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        hintText: tr('confirm_password'),
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return tr('validation_confirm_password_required');
                          }
                          if (v != _newPasswordController.text) {
                            return tr('validation_passwords_mismatch');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 36.h),

                      // ── Submit Button ──────────────────────────────────────
                      if (state is AuthLoading)
                        Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary),
                        )
                      else
                        ElevatedButton(
                          onPressed: _onResetPressed,
                          child: Text('save_the_new_password'.tr()),
                        ),
                      SizedBox(height: 20.h),

                      // ── Back to Login ──────────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.popUntil(context, (r) => r.isFirst),
                          child: Text(
                            'back_to_login'.tr(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: colorScheme.primary,
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
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
