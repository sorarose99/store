import 'dart:ui' as ui;
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

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class ForgotPasswordRequest {
  final String identifier; // email
  ForgotPasswordRequest({required this.identifier});
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ForgotPasswordSubmitted(email: _emailController.text.trim()),
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
          if (state is ForgotPasswordSuccess) {
            // Firebase sent a reset link to the email — just inform the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 4),
              ),
            );
            // Go back to login after short delay
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) Navigator.pop(context);
            });
          } else if (state is AuthError) {
            showAuthSnackBar(context, getLocalizedAuthError(state.message));
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
                      SizedBox(height: 24.h),

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
                            Icons.lock_reset_rounded,
                            color: colorScheme.primary,
                            size: 36,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Title ──────────────────────────────────────────────
                      Center(
                        child: Text(
                          tr('forgot_password'),
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
                          'enter_your_email_and'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 36.h),

                      // ── Email Input ────────────────────────────────────────
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
                          final reg =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!reg.hasMatch(v.trim())) {
                            return tr('validation_email_invalid');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32.h),

                      // ── Send Button ────────────────────────────────────────
                      if (state is AuthLoading)
                        Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary),
                        )
                      else
                        ElevatedButton(
                          onPressed: _onSendPressed,
                          child: Text('send_verification_code'.tr()),
                        ),
                      SizedBox(height: 20.h),

                      // ── Back to login ──────────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
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
