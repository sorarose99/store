import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KdxToast {
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Colors.green.shade700, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, Colors.red.shade700, Icons.error);
  }

  static void _showToast(BuildContext context, String message, Color fallbackColor, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError = icon == Icons.error;
    final bgColor = isError ? colorScheme.error : const Color(0xFF00C48C);
    final onBgColor = isError ? colorScheme.onError : Colors.white;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: onBgColor, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: onBgColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16.w),
        elevation: 6,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
