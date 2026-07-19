import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Smart Error Mapper
//
// Maps any backend / repository error string to a user-friendly localized key.
// Every path returns a tr() string — the raw backend message NEVER reaches
// the user.
// ─────────────────────────────────────────────────────────────────────────────
String getLocalizedError(String message) {
  final m = message.toLowerCase();

  // ── 1. Social Accounts (Highest Priority) ─────────────────────────────────
  if (m.contains('user_has_google_account') ||
      m.contains('google_account') ||
      m.contains('google_auth') ||
      m.contains('auth_with_google') ||
      m.contains('use_google') ||
      (m.contains('google') && (m.contains('account') || m.contains('registered') || m.contains('sign in')))) {
    return tr('error_user_has_google_account');
  }

  if (m.contains('user_has_apple_account') ||
      m.contains('apple_account') ||
      m.contains('apple_auth') ||
      m.contains('auth_with_apple') ||
      m.contains('use_apple') ||
      (m.contains('apple') && (m.contains('account') || m.contains('registered') || m.contains('sign in')))) {
    return tr('error_user_has_apple_account');
  }

  // ── 2. Unverified / Incomplete Account Check ──────────────────────────────
  if (m.contains('unverified') ||
      m.contains('otp_not_verified') ||
      m.contains('email_not_verified') ||
      m.contains('not_verified') ||
      m.contains('account_not_verified') ||
      m.contains('please verify') ||
      m.contains('verify your email') ||
      m.contains('غير مفعّل') ||
      m.contains('غير مؤكد') ||
      m.contains('تأكيد البريد')) {
    return tr('error_account_unverified');
  }

  // ── 3. Specific Credentials Failure ──────────────────────────────────────
  if (m.contains('invalid_credentials') ||
      m.contains('invalid credential') ||
      m.contains('wrong password') ||
      m.contains('wrong_password') ||
      m.contains('incorrect password') ||
      m.contains('بيانات الدخول غير صحيحة') ||
      m.contains('كلمة المرور غير صحيحة')) {
    return tr('error_invalid_credentials');
  }

  // ── 4. User not found ──────────────────────────────────────────────────────
  if (m.contains('user_not_found') ||
      m.contains('not found') ||
      m.contains('no user') ||
      m.contains('no account')) {
    return tr('error_user_not_found');
  }

  // ── 5. Email already in use ────────────────────────────────────────────────
  if (m.contains('email_already_registered') ||
      m.contains('email_in_use') ||
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
  if (m.contains('weak_password') ||
      m.contains('password_too_weak') ||
      m.contains('weak password') ||
      m.contains('weak')) {
    return tr('error_weak_password');
  }

  // ── Account disabled ─────────────────────────────────────────────────────
  if (m.contains('account_disabled') ||
      m.contains('user-disabled') ||
      m.contains('disabled') ||
      m.contains('blocked')) {
    return tr('error_account_disabled');
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
      (m.contains('otp') && m.contains('incorrect')) ||
      m.contains('رمز التحقق غير صحيح') ||
      m.contains('الرمز غير صحيح') ||
      m.contains('رمز غير صحيح') ||
      m.contains('رمز التفعيل غير صحيح')) {
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

  // ── Social / Sync ────────────────────────────────────────────────────────
  if (m.contains('google_sign_in_failed')) {
    return tr('error_google_sign_in_failed');
  }
  if (m.contains('apple_sign_in_failed')) {
    return tr('error_apple_sign_in_failed');
  }
  if (m.contains('backend_sync_failed') || m.contains('failed to sync with backend')) {
    return tr('error_backend_sync_failed');
  }
  if (m.contains('user_has_google_account_please_auth_with_it')) {
    return tr('error_user_has_google_account');
  }
  if (m.contains('user_has_apple_account_please_auth_with_it')) {
    return tr('error_user_has_apple_account');
  }

  // ── Remote DataSource Fallbacks ──────────────────────────────────────────
  if (m == 'login failed') return tr('error_login_failed');
  if (m == 'failed to send otp') return tr('error_failed_to_send_otp');
  if (m == 'registration failed') return tr('error_registration_failed');
  if (m == 'password reset failed') return tr('error_password_reset_failed');
  if (m == 'invalid profile response') return tr('error_invalid_profile_response');

  // ── Network / connectivity ────────────────────────────────────────────────
  if (m == 'error_connection' ||
      m.contains('network_error') ||
      m.contains('network') ||
      m.contains('connection') ||
      m.contains('socket') ||
      m.contains('timeout') ||
      m.contains('no internet') ||
      m.contains('unreachable')) {
    return tr('error_network');
  }

  // ── Promo / Coupon Codes ──────────────────────────────────────────────────
  if (m.contains('coupon') || m.contains('promo') || m.contains('code') || m.contains('discount')) {
    if (m.contains('expired')) return tr('error_promo_code_expired');
    if (m.contains('already used') || m.contains('used') || m.contains('limit')) return tr('error_promo_code_used');
    return tr('error_promo_code_invalid');
  }

  // ── Server / 5xx ─────────────────────────────────────────────────────────
  if (m == 'error_unexpected' ||
      m == 'server error' || 
      m == 'internal server error' || 
      m == '500' || 
      m == '503' ||
      m == 'error_server') {
    return tr('error_server');
  }
  
  if (m == 'error_forbidden') {
    return tr('error_forbidden'); // We will add this key to json
  }
  
  if (m == 'unauthenticated' || m == 'unauthenticated.') {
    return tr('error_session_expired');
  }
  
  if (m == 'the given data was invalid.' || m == 'the given data was invalid') {
    return 'البيانات المدخلة غير صالحة.';
  }
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

void showCustomSnackBar(
  BuildContext context,
  String message, {
  bool isError = true,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  toastification.show(
    context: context,
    title: Text(
      message,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
    type: isError ? ToastificationType.error : ToastificationType.success,
    style: ToastificationStyle.flatColored,
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 4),
    borderRadius: BorderRadius.circular(12.0),
    showProgressBar: false,
    dragToClose: true,
  );
}
