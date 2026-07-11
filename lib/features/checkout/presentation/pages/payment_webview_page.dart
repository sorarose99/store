import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
import '../../data/services/payment_redirect_service.dart';
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
            setState(() => _loading = true);
          },
          onPageFinished: (String url) {
            setState(() => _loading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            
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
      final redirectService = sl<PaymentRedirectService>();
      final checkoutUrl = await redirectService.resolveCheckoutUrl(widget.paymentUrl);

      final Map<String, String> headers = {};
      
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('app_language') ?? 'ar';
      headers['Accept-Language'] = lang;

      await _controller.loadRequest(
        Uri.parse(checkoutUrl),
        headers: headers,
      );
    } catch (e) {
      if (mounted) {
        _onPaymentFailed('${'payment_failed'.tr()}: ${e.toString()}');
      }
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
        body: widget.gateway == 'paytabs'
            ? const Center(child: CircularProgressIndicator())
            : Stack(
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
