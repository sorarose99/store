import 'dart:ui' as ui;
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final RegisterFormData? registerData;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.isPasswordReset = false,
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

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < _otpLength; i++) {
      _focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[i].text.isEmpty &&
            i > 0) {
          _focusNodes[i - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
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
      showAuthSnackBar(context, tr('error_enter_full_otp'));
      return;
    }
    if (widget.isPasswordReset || widget.registerData == null) {
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
          } else if (state is RegisterSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SuccessPage()),
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
                        'email_verification'.tr(),
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
                        'تم إرسال رمز التحقق إلى\n${widget.email}',
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
                    _OtpInputRow(
                      length: _otpLength,
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      onChanged: (code) {
                        _otpCode = code;
                      },
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

// ─────────────────────────────────────────────────────────────────────────────
// OTP Input Row
// ─────────────────────────────────────────────────────────────────────────────
class _OtpInputRow extends StatelessWidget {
  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<String> onChanged;

  const _OtpInputRow({
    required this.length,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < length - 1) {
      focusNodes[index + 1].requestFocus();
    }
    final code = controllers.map((c) => c.text).join();
    onChanged(code);
    if (code.length == length) {
      focusNodes[index].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(length, (index) {
          return Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0.w),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: TextFormField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.4),
                          width: 1.2.w),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.w),
                    ),
                  ),
                  onChanged: (value) => _onChanged(value, index),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

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
