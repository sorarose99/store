import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import 'reset_password_page.dart';
import 'success_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────
class OtpVerificationData {
  final String phoneNumber;
  final bool isPasswordReset;
  const OtpVerificationData({
    required this.phoneNumber,
    required this.isPasswordReset,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final bool isPasswordReset;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    this.isPasswordReset = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  static const int _otpLength = 4;
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
    context.read<AuthBloc>().add(
          ForgotPasswordSubmitted(phoneNumber: widget.phoneNumber),
        );
    _startTimer();
  }

  void _onSubmit() {
    if (_otpCode.length < _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال الرمز كاملاً'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(
          VerifyOtpSubmitted(
            phoneNumber: widget.phoneNumber,
            otpCode: _otpCode,
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
          if (state is OtpVerificationSuccess) {
            if (widget.isPasswordReset) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ResetPasswordPage(phoneNumber: widget.phoneNumber),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SuccessPage()),
              );
            }
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ── Phone Icon ──────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sms_outlined,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Title ───────────────────────────────────────────────
                    const Center(
                      child: Text(
                        'التحقق من رقم الهاتف',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Subtitle ────────────────────────────────────────────
                    Center(
                      child: Text(
                        'تم إرسال رمز التحقق إلى\n${widget.phoneNumber}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ── OTP Boxes ───────────────────────────────────────────
                    _OtpInputRow(
                      length: _otpLength,
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      onCompleted: (code) {
                        _otpCode = code;
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Countdown / Resend ──────────────────────────────────
                    _ResendRow(
                      secondsRemaining: _secondsRemaining,
                      canResend: _canResend,
                      onResend: _onResendOtp,
                    ),
                    const SizedBox(height: 40),

                    // ── Submit Button ───────────────────────────────────────
                    if (state is AuthLoading)
                      const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      )
                    else
                      ElevatedButton(
                        onPressed: _onSubmit,
                        child: const Text('تأكيد الرمز'),
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
  final ValueChanged<String> onCompleted;

  const _OtpInputRow({
    required this.length,
    required this.controllers,
    required this.focusNodes,
    required this.onCompleted,
  });

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < length - 1) {
      focusNodes[index + 1].requestFocus();
    }
    final code = controllers.map((c) => c.text).join();
    if (code.length == length) {
      focusNodes[index].unfocus();
      onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(length, (index) {
          return SizedBox(
            width: 62,
            height: 62,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    controllers[index].text.isEmpty &&
                    index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
              },
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (value) => _onChanged(value, index),
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
    final pad = secondsRemaining < 10
        ? '0$secondsRemaining'
        : '$secondsRemaining';

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'لم تستلم الرمز؟ ',
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          GestureDetector(
            onTap: canResend ? onResend : null,
            child: canResend
                ? const Text(
                    'إعادة الإرسال',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  )
                : Text(
                    'إعادة الإرسال (0:$pad)',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
