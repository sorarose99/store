import 'dart:developer' as developer;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/colors.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
import 'checkout_success_page.dart';


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

      // Payment URLs should NEVER get the Authorization header.
      // Even our own backend payment endpoints (/payments/paytabs/pay etc.)
      // return JSON when they see an Authorization header — they expect
      // a browser redirect flow, not an authenticated API call.
      // Always load with plain browser headers only.
      final Map<String, String> headers = {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': lang,
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      };

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
      final bodyText = await _controller
          .runJavaScriptReturningResult('document.body.innerText');
      final raw = bodyText.toString().replaceAll(r'\"', '"');
      developer.log('[PaymentWebView] Page body (first 500): ${raw.substring(0, raw.length.clamp(0, 500))}');

      // Look for redirect_url / payment_url in the JSON body
      final patterns = [
        RegExp(r'"redirect_url"\s*:\s*"([^"]+)"'),
        RegExp(r'"payment_url"\s*:\s*"([^"]+)"'),
        RegExp(r'"url"\s*:\s*"(https?://[^"]+)"'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(raw);
        if (match != null) {
          var redirectUrl = match.group(1)!
              .replaceAll(r'\/', '/')
              .replaceAll('\\u0026', '&');
          developer.log('[PaymentWebView] Found redirect URL in JSON: $redirectUrl');
          if (mounted) {
            await _controller.loadRequest(
              Uri.parse(redirectUrl),
              headers: {
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              },
            );
          }
          return;
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
    context.read<CartBloc>().add(const CartCleared());
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => CheckoutSuccessPage(orderNumber: widget.orderNumber),
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
