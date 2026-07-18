import 'dart:developer' as developer;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../core/constants/colors.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
import 'checkout_success_page.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/services/payment_redirect_service.dart';



enum PaymentFlowResult { success, cancelled, failed }

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String orderNumber;
  final String gateway;

  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    required this.orderNumber,
    required this.gateway,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }



  Future<void> _initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            developer.log('[PaymentWebView] Loading: $url');
            setState(() => _loading = true);
          },
          onPageFinished: (String url) {
            developer.log('[PaymentWebView] Finished: $url');
            setState(() => _loading = false);

            // ── If the WebView lands on a JSON-returning API endpoint,
            //    the page content will be raw JSON. We detect this by
            //    evaluating the document body and looking for JSON.
            _checkIfPageIsJson(url);
          },
          onWebResourceError: (WebResourceError error) {
            developer.log(
                '[PaymentWebView] Error ${error.errorCode}: ${error.description} at ${error.url}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            developer.log('[PaymentWebView] Navigation request: ${request.url}');

            if (_isSuccessUrl(url)) {
              _onPaymentSuccess();
              return NavigationDecision.prevent;
            } else if (_isCancelUrl(url)) {
              _onPaymentCancelled();
              return NavigationDecision.prevent;
            } else if (_isFailureUrl(url)) {
              _onPaymentFailed('payment_failed'.tr());
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('app_language') ?? 'ar';

      // ── Use PaymentRedirectService to inject the Bearer token ──
      // This is mandatory for backend routes protected by the auth:sanctum middleware.
      final headers = await di.sl<PaymentRedirectService>().buildHeaders(lang);
      headers['User-Agent'] =
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

      await _controller.loadRequest(
        Uri.parse(widget.paymentUrl),
        headers: headers,
      );
    } catch (e) {
      developer.log('[PaymentWebView] Init error: $e');
      if (mounted) {
        _onPaymentFailed('${'payment_failed'.tr()}: ${e.toString()}');
      }
    }
  }

  /// Evaluates the page body to detect if raw JSON is being shown.
  /// If so, tries to parse the redirect URL from it.
  Future<void> _checkIfPageIsJson(String url) async {
    if (!url.contains('kdx-sa.com')) return;
    try {
      final jsResult = await _controller.runJavaScriptReturningResult('document.body.innerText');
      String innerText = jsResult.toString();

      // runJavaScriptReturningResult returns a JSON-serialized string (surrounded by quotes and escaped).
      // We decode it once to get the actual plain text of the document body.
      try {
        final decoded = jsonDecode(innerText);
        if (decoded is String) {
          innerText = decoded;
        }
      } catch (_) {}

      developer.log('[PaymentWebView] Page body (first 500): ${innerText.substring(0, innerText.length.clamp(0, 500))}');

      // Now parse the inner text as JSON
      final Map<String, dynamic> data = jsonDecode(innerText) as Map<String, dynamic>;
      final redirectUrl = data['redirect_url'] ?? data['payment_url'] ?? data['url'];

      if (redirectUrl != null) {
        final cleanUrl = redirectUrl.toString().trim();
        developer.log('[PaymentWebView] Found redirect URL in JSON: $cleanUrl');
        if (mounted) {
          await _controller.loadRequest(
            Uri.parse(cleanUrl),
            headers: {
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            },
          );
        }
      }
    } catch (e) {
      developer.log('[PaymentWebView] JSON check error: $e');
    }
  }

  bool _isSuccessUrl(String url) {
    return url.contains('/orders/success') ||
        url.contains('/payment/success') ||
        url.contains('/payments/tamara/success') ||
        url.contains('/payments/tabby/success') ||
        url.contains('/payments/paytabs/success') ||
        url.contains('status=approved') ||
        url.contains('payment_status=success');
  }

  bool _isCancelUrl(String url) {
    return url.contains('/orders/cancel') ||
        url.contains('/payment/cancel') ||
        url.contains('/payments/tamara/cancel') ||
        url.contains('/payments/tabby/cancel') ||
        url.contains('/payments/paytabs/cancel') ||
        url.contains('status=cancel');
  }

  bool _isFailureUrl(String url) {
    return url.contains('/orders/fail') ||
        url.contains('/payment/fail') ||
        url.contains('/payments/tamara/fail') ||
        url.contains('/payments/tabby/fail') ||
        url.contains('/payments/paytabs/fail') ||
        url.contains('status=failed') ||
        url.contains('status=declined');
  }

  void _onPaymentSuccess() {
    final needsPolling = widget.gateway == 'tabby' || widget.gateway == 'tamara';
    if (!needsPolling) {
      context.read<CartBloc>().add(const CartCleared());
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => CheckoutSuccessPage(
          orderNumber: widget.orderNumber,
          requiresPolling: needsPolling,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _onPaymentCancelled() {
    Navigator.of(context).pop(PaymentFlowResult.cancelled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('payment_has_been_cancelled'.tr())),
    );
  }

  void _onPaymentFailed(String message) {
    Navigator.of(context).pop(PaymentFlowResult.failed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.errorColor,
      ),
    );
  }

  String get _title {
    switch (widget.gateway) {
      case 'tabby':
        return 'payment_via_tabby'.tr();
      case 'tamara':
        return 'payment_via_tamara'.tr();
      default:
        return 'complete_payment'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: context.textDark),
            onPressed: _onPaymentCancelled,
          ),
          title: Text(
            _title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
              color: context.textDark,
            ),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
