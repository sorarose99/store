import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/network/token_service.dart';

/// Resolves the backend payment initiation URL into the final
/// Tabby/Tamara/PayTabs hosted checkout URL using Sanctum auth.
class PaymentRedirectService {
  final TokenService _tokenService;

  PaymentRedirectService(this._tokenService);

  Future<Map<String, String>> _authHeaders() async {
    final headers = <String, String>{
      'Accept': 'text/html,application/json',
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

  Future<String> resolveCheckoutUrl(String paymentUrl) async {
    final dio = Dio(
      BaseOptions(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    var current = paymentUrl;

    for (var i = 0; i < 10; i++) {
      if (_isExternalCheckout(current)) return current;

      final response = await dio.get<String>(
        current,
        options: Options(
          headers: await _authHeaders(),
          responseType: ResponseType.plain,
        ),
      );

      final status = response.statusCode ?? 0;
      if (status == 301 ||
          status == 302 ||
          status == 303 ||
          status == 307 ||
          status == 308) {
        final location = response.headers.value('location');
        if (location == null || location.isEmpty) break;
        current = _resolveUrl(current, location);
        continue;
      }

      if (status == 200 && _isExternalCheckout(current)) {
        return current;
      }

      break;
    }

    return current;
  }

  bool _isExternalCheckout(String url) {
    final lower = url.toLowerCase();
    return lower.contains('tabby.ai') ||
        lower.contains('tamara.co') ||
        lower.contains('paytabs.com') ||
        lower.contains('secure.paytabs');
  }

  String _resolveUrl(String base, String location) {
    if (location.startsWith('http')) return location;
    final baseUri = Uri.parse(base);
    return baseUri.resolve(location).toString();
  }
}
