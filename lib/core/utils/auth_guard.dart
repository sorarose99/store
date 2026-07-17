import 'package:flutter/material.dart';
import 'package:kdx/core/network/token_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../di/injection_container.dart';

/// Guards authenticated-only actions (wishlist, checkout, etc.).
class AuthGuard {
  AuthGuard._();

  static bool get isLoggedIn {
    return sl<TokenService>().hasToken;
  }

  /// Returns true when the user is logged in. Otherwise navigates to [LoginPage].
  static Future<bool> requireLogin(BuildContext context) async {
    if (isLoggedIn) return true;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    return isLoggedIn;
  }
}
