import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/social_auth_button.dart';
import 'otp_verification_page.dart';
import 'terms_acceptance_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class RegisterFormData {
  final String name;
  final String email;
  final String phone;
  final String password;
  final bool agreedToTerms;

  const RegisterFormData({
    required this.name,
    required this.email,
    required this.phone,
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
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedCountryCode = '+966';
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على الشروط والأحكام'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final phone = '$_selectedCountryCode${_phoneController.text.trim()}';
    context.read<AuthBloc>().add(
          RegisterSubmitted(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: phone,
            password: _passwordController.text,
          ),
        );
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
          if (state is RegisterSuccess) {
            final phone =
                '$_selectedCountryCode${_phoneController.text.trim()}';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationPage(
                  phoneNumber: phone,
                  isPasswordReset: false,
                ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 4),

                      // ── Title ──────────────────────────────────────────────
                      const Center(
                        child: Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'يرجى التسجيل في التطبيق للبدء',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Full Name ──────────────────────────────────────────
                      const _FieldLabel(text: 'الاسم الكامل'),
                      const SizedBox(height: 6),
                      AuthTextField(
                        controller: _nameController,
                        hintText: 'الاسم بالكامل',
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'يرجى إدخال الاسم';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Phone ──────────────────────────────────────────────
                      PhoneInputField(
                        controller: _phoneController,
                        labelText: 'رقم الهاتف',
                        onCountryChanged: (c) =>
                            _selectedCountryCode = c.code,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'يرجى إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Email ──────────────────────────────────────────────
                      const _FieldLabel(text: 'البريد الإلكتروني'),
                      const SizedBox(height: 6),
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'example@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'يرجى إدخال البريد الإلكتروني';
                          }
                          final reg =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!reg.hasMatch(v.trim())) {
                            return 'يرجى إدخال بريد إلكتروني صالح';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Password ───────────────────────────────────────────
                      const _FieldLabel(text: 'كلمة المرور'),
                      const SizedBox(height: 6),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'أدخل كلمة المرور',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'يرجى إدخال كلمة المرور';
                          }
                          if (v.length < 6) {
                            return 'يجب أن تكون 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

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
                          if (v != _passwordController.text) {
                            return 'كلمات المرور غير متطابقة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

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
                      const SizedBox(height: 28),

                      // ── Register Button ────────────────────────────────────
                      if (state is AuthLoading)
                        const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        )
                      else
                        ElevatedButton(
                          onPressed: _onRegisterPressed,
                          child: const Text('إنشاء حساب'),
                        ),
                      const SizedBox(height: 20),

                      // ── Divider ────────────────────────────────────────────
                      const _OrDivider(label: 'أو تسجيل عبر'),
                      const SizedBox(height: 16),

                      // ── Social Auth ────────────────────────────────────────
                      SocialAuthButton(isApple: true, onTap: () {}),
                      const SizedBox(height: 10),
                      SocialAuthButton(isApple: false, onTap: () {}),
                      const SizedBox(height: 28),

                      // ── Login Link ─────────────────────────────────────────
                      _AuthFooterLink(
                        question: 'هل لديك حساب بالفعل؟ ',
                        actionLabel: 'تسجيل الدخول',
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 24),
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

class _OrDivider extends StatelessWidget {
  final String label;
  const _OrDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
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
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
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

  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: value,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: AppColors.border, width: 1.5),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'بالتسجيل أنت توافق على '),
                TextSpan(
                  text: 'الشروط والأحكام',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
                const TextSpan(text: ' وسياسة الخصوصية'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
