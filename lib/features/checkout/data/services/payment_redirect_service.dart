import 'dart:developer' as developer;
import 'dart:convert';
import 'package:dio/dio.dart';
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

  /// Resolves the payment URL if it's an API route requiring authentication.
  /// Pre-fetches the initial redirect so third-party payment gateways (Tabby/Tamara)
  /// receive clean requests in the WebView without internal backend Bearer tokens.
  Future<String> resolveCheckoutUrl(String paymentUrl) async {
    if (!paymentUrl.contains('kdx-sa.com') || !paymentUrl.contains('/api/payments/')) {
      return paymentUrl;
    }

    try {
      developer.log('[PaymentRedirectService] Resolving initial payment URL: $paymentUrl');
      final headers = await buildHeaders('ar');

      final dio = Dio(BaseOptions(
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status != null && status < 500,
      ));

      final response = await dio.get(
        paymentUrl,
        options: Options(
          headers: headers,
        ),
      );

      final realUri = response.realUri.toString();
      developer.log('[PaymentRedirectService] Resolved real URI: $realUri (status: ${response.statusCode})');

      if (realUri.isNotEmpty && realUri != paymentUrl && !realUri.contains('kdx-sa.com/api/payments/')) {
        return realUri.replaceAll('lang=ara', 'lang=ar').replaceAll('lang=arb', 'lang=ar');
      }

      // ── Parse JSON response if backend returned a JSON object with payment_url/redirect_url ──
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map) {
        final extractedUrl = data['payment_url'] ?? data['redirect_url'] ?? data['url'];
        if (extractedUrl != null && extractedUrl.toString().trim().isNotEmpty) {
          String cleanUrl = extractedUrl.toString().trim();
          cleanUrl = cleanUrl.replaceAll('lang=ara', 'lang=ar').replaceAll('lang=arb', 'lang=ar');
          developer.log('[PaymentRedirectService] Extracted payment URL from JSON response: $cleanUrl');
          return cleanUrl;
        }
      }
    } catch (e) {
      developer.log('[PaymentRedirectService] Error resolving URL: $e');
    }

    return paymentUrl;
  }
}
