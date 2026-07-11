import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_handler.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_text_field.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../../../shell/presentation/pages/main_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Request Model
// ─────────────────────────────────────────────────────────────────────────────
class LoginRequest {
  final String identifier; // email
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.identifier,
    required this.password,
    this.rememberMe = true,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess || state is SocialLoginSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShell()),
              (route) => false,
            );
          } else if (state is AuthError) {
            showAuthSnackBar(context, getLocalizedAuthError(state.message));
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
                      SizedBox(height: 32.h),

                      // ── App Logo ───────────────────────────────────────────
                      const _AppLogo(),
                      SizedBox(height: 28.h),

                      // ── Title ──────────────────────────────────────────────
                      Center(
                        child: Text(
                          tr('login'),
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
                          'please_log_in_to'.tr(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),

                      // ── Email ──────────────────────────────────────
                      _FieldLabel(text: tr('email')),
                      SizedBox(height: 6.h),
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'example@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: ui.TextDirection.ltr,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return tr('validation_email_required');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // ── Password ───────────────────────────────────────────
                      _FieldLabel(text: tr('password')),
                      SizedBox(height: 6.h),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: tr('password'),
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return tr('validation_password_required');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),

                      // ── Remember Me & Forgot Password ──────────────────────
                      _RememberForgotRow(
                        rememberMe: _rememberMe,
                        onRememberChanged: (val) =>
                            setState(() => _rememberMe = val ?? false),
                        onForgotTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage()),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Login Button ──────────────────────────────────────
                      if (state is AuthLoading)
                        Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary),
                        )
                      else
                        ElevatedButton(
                          onPressed: _onLoginPressed,
                          child: Text(tr('login')),
                        ),
                      SizedBox(height: 24.h),

                      // ── Register Link ──────────────────────────────────────
                      _AuthFooterLink(
                        question: 'dont_have_an_account'.tr(),
                        actionLabel: tr('register'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Social Login ───────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                              child:
                                  Divider(color: colorScheme.outlineVariant)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              'or_login_using'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                              child:
                                  Divider(color: colorScheme.outlineVariant)),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialLoginButton(
                            onTap: state is AuthLoading
                                ? () {}
                                : () {
                                    context
                                        .read<AuthBloc>()
                                        .add(const GoogleSignInSubmitted());
                                  },
                            child: Image.asset(
                              'assets/images/google_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          _SocialLoginButton(
                            onTap: state is AuthLoading
                                ? () {}
                                : () {
                                    context
                                        .read<AuthBloc>()
                                        .add(const AppleSignInSubmitted());
                                   },
                            child: Image.asset(
                              'assets/images/apple_logo.png',
                              fit: BoxFit.contain,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
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
// Shared Private Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/logo.png',
          width: 80.w,
          height: 80.h,
          fit: BoxFit.cover,
        ),
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

class _RememberForgotRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onForgotTap;
  const _RememberForgotRow({
    required this.rememberMe,
    required this.onRememberChanged,
    required this.onForgotTap,
  });  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => onRememberChanged(!rememberMe),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22.w,
                height: 22.h,
                child: Checkbox(
                  value: rememberMe,
                  activeColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                      width: 1.5.w),
                  onChanged: onRememberChanged,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'remember_me'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onForgotTap,
          child: Text(
            tr('forgot_password'),
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _SocialLoginButton({
    required this.child,
    required this.onTap,
  });  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: 28.w,
          height: 28.h,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _AuthFooterLink extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;
  const _AuthFooterLink({
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });  @override
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
