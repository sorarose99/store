import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/token_service.dart';

/// Provides authenticated headers for the WebView's initial payment URL load.
/// The WebView handles all subsequent redirects natively.
class PaymentRedirectService {
  final TokenService _tokenService;

  PaymentRedirectService(this._tokenService);

  /// Returns auth headers to attach to the initial WebView loadRequest call.
  /// The WebView follows redirects on its own from that point.
  Future<Map<String, String>> buildHeaders(String language) async {
    final headers = <String, String>{
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': language,
      'Cookie': 'locale=$language',
    };

    final sanctum = _tokenService.getSanctumToken();
    if (sanctum != null && sanctum.isNotEmpty) {
      headers['Authorization'] = 'Bearer $sanctum';
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final firebaseToken = await user.getIdToken();
        if (firebaseToken != null && firebaseToken.isNotEmpty) {
          headers['X-Firebase-Token'] = firebaseToken;
        }
      } catch (_) {}
    }

    return headers;
  }

  /// Returns the payment URL unchanged.
  /// The WebView is responsible for following all redirects.
  Future<String> resolveCheckoutUrl(String paymentUrl) async {
    return paymentUrl;
  }
}
