import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/colors.dart';
import '../../data/datasources/mock_account_data.dart';
import 'delete_account_reason_page.dart';

class DeleteAccountOtpPage extends StatefulWidget {
  const DeleteAccountOtpPage({super.key});

  @override
  State<DeleteAccountOtpPage> createState() => _DeleteAccountOtpPageState();
}

class _DeleteAccountOtpPageState extends State<DeleteAccountOtpPage> {
  String _otpCode = '';
  int _secondsLeft = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsLeft = 59;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic email from the mock data
    final user = MockAccountDataSource.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textDark,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'حذف الحساب',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'التحقق من الحساب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لحماية سلامة حسابك، نحتاج إلى التحقق من الحساب، سنرسل رمز التحقق إلى بريدك الإلكتروني [${user.email}]، يرجى إدخال الرمز المكون من 5 أرقام.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: AppColors.textMid,
                        ),
                      ),
                      const SizedBox(height: 36),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Pinput(
                          length: 5,
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
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              border: Border.all(color: const Color(0xFFEEEEEE)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 56.w,
                            height: 56.h,
                            textStyle: TextStyle(
                              fontSize: 22.sp,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.primary, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  blurRadius: 8,
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
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              border: Border.all(color: const Color(0xFFEEEEEE)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Resend Code or Timer
                      Center(
                        child: _secondsLeft > 0
                            ? Text(
                                '$_secondsLeft ثانية',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                              )
                            : InkWell(
                                onTap: _startTimer,
                                child: const Text(
                                  'إعادة إرسال الرمز',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _otpCode.length == 5
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DeleteAccountReasonPage(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تأكيد الطلب',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Deleted custom OtpInputRow
