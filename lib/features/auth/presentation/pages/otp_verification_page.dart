import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/utils/error_handler.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import 'register_page.dart';
import 'reset_password_page.dart';
import 'success_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class OtpVerificationData {
  final String email;
  final bool isPasswordReset;
  OtpVerificationData({
    required this.email,
    required this.isPasswordReset,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool isPasswordReset;
  final bool isRecoveryFallback;
  final RegisterFormData? registerData;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.isPasswordReset = false,
    this.isRecoveryFallback = false,
    this.registerData,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int _otpLength = 6;
  static const int _timerDuration = 60;

  String _otpCode = '';
  int _secondsRemaining = _timerDuration;
  bool _canResend = false;
  Timer? _timer;

  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = _timerDuration;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  void _onResendOtp() {
    if (!_canResend) return;
    // Clear inputs
    _otpController.clear();
    setState(() {
      _otpCode = '';
    });
    if (widget.isPasswordReset) {
      context.read<AuthBloc>().add(
            ForgotPasswordSubmitted(email: widget.email),
          );
    } else {
      context.read<AuthBloc>().add(
            RegisterOtpRequested(email: widget.email),
          );
    }
    _startTimer();
  }

  void _onSubmit() {
    if (_otpCode.length < _otpLength) {
      showCustomSnackBar(context, tr('error_enter_full_otp'));
      return;
    }
    if (widget.isRecoveryFallback && widget.registerData != null) {
      context.read<AuthBloc>().add(
            ResetPasswordSubmitted(
              email: widget.email,
              otpCode: _otpCode,
              newPassword: widget.registerData!.password,
            ),
          );
    } else if (widget.isPasswordReset || widget.registerData == null) {
      context.read<AuthBloc>().add(
            VerifyOtpSubmitted(
              email: widget.email,
              otpCode: _otpCode,
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            RegisterSubmitted(
              name: widget.registerData!.name,
              email: widget.registerData!.email,
              password: widget.registerData!.password,
              otpCode: _otpCode,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            if (widget.isPasswordReset) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ResetPasswordPage(email: widget.email, otpCode: _otpCode),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SuccessPage()),
              );
            }
          } else if (state is RegisterSuccess || state is ResetPasswordSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SuccessPage()),
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
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16.h),

                    // ── Email Icon ──────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 72.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 34,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Title ───────────────────────────────────────────────
                    Center(
                      child: Text(
                        widget.isRecoveryFallback
                            ? tr('continue_with_otp')
                            : (widget.isPasswordReset
                                ? tr('forgot_password')
                                : tr('email_verification')),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // ── Subtitle ────────────────────────────────────────────
                    Center(
                      child: Text(
                        widget.isRecoveryFallback
                            ? tr('continue_otp_unverified_desc')
                            : '${'code_sent_to'.tr()}\n${widget.email}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.6.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // ── OTP Boxes ───────────────────────────────────────────
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Pinput(
                        length: _otpLength,
                        controller: _otpController,
                      onChanged: (code) {
                        setState(() {
                          _otpCode = code;
                        });
                      },
                      onCompleted: (code) {
                        setState(() {
                          _otpCode = code;
                        });
                      },
                      defaultPinTheme: PinTheme(
                        width: 56.w,
                        height: 56.h,
                        textStyle: TextStyle(
                          fontSize: 22.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.4),
                            width: 1.2.w,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 56.w,
                        height: 56.h,
                        textStyle: TextStyle(
                          fontSize: 22.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary, width: 2.w),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 56.w,
                        height: 56.h,
                        textStyle: TextStyle(
                          fontSize: 22.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.4),
                            width: 1.2.w,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),

                    // ── Countdown / Resend ──────────────────────────────────
                    _ResendRow(
                      secondsRemaining: _secondsRemaining,
                      canResend: _canResend,
                      onResend: _onResendOtp,
                    ),
                    SizedBox(height: 40.h),

                    // ── Submit Button ───────────────────────────────────────
                    if (state is AuthLoading)
                      Center(
                        child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary),
                      )
                    else
                      ElevatedButton(
                        onPressed: _onSubmit,
                        child: Text('confirm_the_code'.tr()),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Deleted custom _OtpInputRow

// ─────────────────────────────────────────────────────────────────────────────
// Resend Row
// ─────────────────────────────────────────────────────────────────────────────
class _ResendRow extends StatelessWidget {
  final int secondsRemaining;
  final bool canResend;
  final VoidCallback onResend;

  const _ResendRow({
    required this.secondsRemaining,
    required this.canResend,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final pad =
        secondsRemaining < 10 ? '0$secondsRemaining' : '$secondsRemaining';

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'didnt_receive_the_code'.tr(),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13.sp),
          ),
          GestureDetector(
            onTap: canResend ? onResend : null,
            child: canResend
                ? Text(
                    'rebroadcast'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  )
                : Text(
                    'إعادة الإرسال (0:$pad)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13.sp,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
