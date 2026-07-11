import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kdx/core/network/token_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../di/injection_container.dart';

/// Guards authenticated-only actions (wishlist, checkout, etc.).
class AuthGuard {
  AuthGuard._();

  static bool get isLoggedIn {
    final hasFirebase = FirebaseAuth.instance.currentUser != null;
    final hasSanctum = sl<TokenService>().getSanctumToken() != null;
    return hasFirebase || hasSanctum;
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
