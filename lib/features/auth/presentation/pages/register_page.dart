import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
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
import 'otp_verification_page.dart';
import 'terms_acceptance_page.dart';
import 'login_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class RegisterFormData {
  final String name;
  final String email;
  final String password;
  final bool agreedToTerms;

  RegisterFormData({
    required this.name,
    required this.email,
    required this.password,
    required this.agreedToTerms,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      showAuthSnackBar(context, tr('error_accept_terms'));
      return;
    }
    context.read<AuthBloc>().add(
          RegisterOtpRequested(
            email: _emailController.text.trim(),
          ),
        );
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
          if (state is RegisterOtpSendSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationPage(
                  email: _emailController.text.trim(),
                  isPasswordReset: false,
                  registerData: RegisterFormData(
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                    agreedToTerms: _agreedToTerms,
                  ),
                ),
              ),
            );
          } else if (state is AuthError) {
            final msg = getLocalizedAuthError(state.message);
            final isEmailInUse = msg == tr('error_email_in_use');
            showAuthSnackBar(
              context,
              msg,
              actionLabel: isEmailInUse ? 'login'.tr() : null,
              onAction: isEmailInUse
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  : null,
            );
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: Directionality.of(context),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 4.h),

                      // ── Title ──────────────────────────────────────────────
                      Center(
                        child: Text(
                          tr('register'),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Center(
                        child: Text(
                          'please_register_in_the'.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Full Name ──────────────────────────────────────────
                      _FieldLabel(text: tr('name')),
                      SizedBox(height: 6.h),
                      AuthTextField(
                        controller: _nameController,
                        hintText: tr('name'),
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return tr('validation_name_required');
                          }
                          if (!v.trim().contains(' ')) {
                            return tr('validation_name_full_required');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),

                      SizedBox(height: 14.h),

                      // ── Email ──────────────────────────────────────────────
                      _FieldLabel(text: tr('email')),
                      SizedBox(height: 6.h),
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'example@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: ui.TextDirection.ltr,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return tr('validation_email_required');
                          }
                          final reg =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!reg.hasMatch(v.trim())) {
                            return tr('validation_email_invalid');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),

                      // ── Password ───────────────────────────────────────────
                      _FieldLabel(text: tr('password')),
                      SizedBox(height: 6.h),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: tr('password'),
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return tr('validation_password_required');
                          }
                          if (v.length < 6) {
                            return tr('validation_password_min_length');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),

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
                          if (v != _passwordController.text) {
                            return tr('validation_passwords_mismatch');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),

                      // ── Terms Checkbox ─────────────────────────────────────
                      _TermsCheckbox(
                        value: _agreedToTerms,
                        onChanged: (val) =>
                            setState(() => _agreedToTerms = val ?? false),
                        onTermsTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TermsAcceptancePage()),
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // ── Register Button ────────────────────────────────────
                      if (state is AuthLoading)
                        Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary),
                        )
                      else
                        ElevatedButton(
                          onPressed: _onRegisterPressed,
                          child: Text(tr('register')),
                        ),
                      SizedBox(height: 20.h),

                      // ── Login Link ─────────────────────────────────────────
                      _AuthFooterLink(
                        question: 'do_you_already_have'.tr(),
                        actionLabel: tr('login'),
                        onTap: () => Navigator.pop(context),
                      ),
                      SizedBox(height: 24.h),
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

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;const 
  _FieldLabel({required this.text});

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

class _AuthFooterLink extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;
const 
  _AuthFooterLink({
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style:
              TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13.sp),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ),
      ],
    );
  }
}

/// Checkbox row with rich-text "I agree to Terms & Privacy"
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;
const 
  _TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22.w,
          height: 22.h,
          child: Checkbox(
            value: value,
            activeColor: colorScheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1.5.w),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.4.h,
              ),
              children: [
                TextSpan(text: 'by_registering_you_agree'.tr()),
                TextSpan(
                  text: tr('terms_conditions'),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
                TextSpan(text: 'and_privacy_policy'.tr()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
