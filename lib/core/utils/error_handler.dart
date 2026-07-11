import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kdx/core/constants/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Smart Error Mapper
//
// Maps any backend / repository error string to a user-friendly localized key.
// Every path returns a tr() string — the raw backend message NEVER reaches
// the user.
// ─────────────────────────────────────────────────────────────────────────────
String getLocalizedAuthError(String message) {
  final m = message.toLowerCase();

  // ── Credentials ───────────────────────────────────────────────────────────
  if (m.contains('invalid_credentials') ||
      m.contains('invalid credential') ||
      m.contains('wrong password') ||
      m.contains('incorrect') ||
      m.contains('unauthenticated') ||
      m.contains('401')) {
    return tr('error_invalid_credentials');
  }

  // ── User not found ────────────────────────────────────────────────────────
  if (m.contains('user_not_found') ||
      m.contains('not found') ||
      m.contains('no user') ||
      m.contains('no account') ||
      m.contains('404')) {
    return tr('error_user_not_found');
  }

  // ── Email already in use ──────────────────────────────────────────────────
  if (m.contains('email_in_use') ||
      m.contains('already exists') ||
      m.contains('already in use') ||
      m.contains('already taken') ||
      m.contains('duplicate') ||
      m.contains('has already been taken') ||
      m.contains('مستخدم') ||
      m.contains('مأخوذ')) {
    return tr('error_email_in_use');
  }

  // ── Weak password ─────────────────────────────────────────────────────────
  if (m.contains('password_too_weak') ||
      m.contains('weak password') ||
      m.contains('weak')) {
    return tr('error_weak_password');
  }

  // ── Invalid email format ──────────────────────────────────────────────────
  if (m.contains('invalid_email') ||
      m.contains('invalid email') ||
      m.contains('email format')) {
    return tr('error_invalid_email');
  }

  // ── OTP expired ───────────────────────────────────────────────────────────
  if (m.contains('otp_expired') ||
      m.contains('code expired') ||
      m.contains('expired') ||
      m.contains('otp expired')) {
    return tr('error_otp_expired');
  }

  // ── OTP invalid ───────────────────────────────────────────────────────────
  if (m.contains('otp_invalid') ||
      m.contains('invalid code') ||
      m.contains('wrong code') ||
      m.contains('invalid otp') ||
      m.contains('otp') && m.contains('incorrect')) {
    return tr('error_otp_invalid');
  }

  // ── Too many requests / rate limiting ─────────────────────────────────────
  if (m.contains('too_many_requests') ||
      m.contains('too many') ||
      m.contains('rate limit') ||
      m.contains('throttle') ||
      m.contains('429')) {
    return tr('error_too_many_requests');
  }

  // ── Session / token expired ───────────────────────────────────────────────
  if (m.contains('session_expired') ||
      m.contains('token') ||
      m.contains('unauthorized') ||
      m.contains('unauthenticated') ||
      m.contains('session')) {
    return tr('error_session_expired');
  }

  // ── Network / connectivity ────────────────────────────────────────────────
  if (m.contains('network_error') ||
      m.contains('network') ||
      m.contains('connection') ||
      m.contains('socket') ||
      m.contains('timeout') ||
      m.contains('no internet') ||
      m.contains('unreachable')) {
    return tr('error_network');
  }

  // ── Server / 5xx ─────────────────────────────────────────────────────────
  if (m.contains('server_error') ||
      m.contains('server error') ||
      m.contains('internal') ||
      m.contains('500') ||
      m.contains('503')) {
    return tr('error_server');
  }

  // ── Generic fallback — Returns raw backend text so user sees the real issue ──
  // Do NOT swallow into 'Something went wrong' unless we truly have nothing.
  return message;
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium SnackBar Helper
//
// Use this everywhere instead of raw ScaffoldMessenger calls.
// • Hides any currently visible SnackBar first (prevents stacking)
// • Theme-dynamic: reads error/success colors from ColorScheme
// • Rounded, floating, with leading icon
// • 4-second duration (sufficient for Arabic text)
// ─────────────────────────────────────────────────────────────────────────────
void showAuthSnackBar(
  BuildContext context,
  String message, {
  bool isError = true,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final bgColor = isError ? colorScheme.error : context.primaryColor;
  final onBgColor = isError ? colorScheme.onError : context.backgroundColor;
  final icon = isError
      ? Icons.error_outline_rounded
      : Icons.check_circle_outline_rounded;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: onBgColor, size: 20),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: onBgColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.4.h,
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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
        elevation: 4,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: context.backgroundColor,
                onPressed: onAction,
              )
            : null,
      ),
    );
}
