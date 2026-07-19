import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdx/features/checkout/data/services/native_payment_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_state.dart';
import '../../../account/presentation/blocs/account_bloc.dart';
import '../../../account/presentation/blocs/account_state.dart';
import 'checkout_success_page.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../../domain/entities/checkout_entities.dart';
import '../blocs/checkout_bloc.dart';
import '../blocs/checkout_event.dart';
import '../blocs/checkout_state.dart';
import 'checkout_payment_page.dart';
import 'payment_webview_page.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:dio/dio.dart';



class CheckoutReviewPage extends StatefulWidget {
  final SavedAddressEntity address;
  final PaymentMethod paymentMethod;
  final String initialComment;

  const CheckoutReviewPage({
    super.key,
    required this.address,
    required this.paymentMethod,
    this.initialComment = '',
  });

  @override
  State<CheckoutReviewPage> createState() => _CheckoutReviewPageState();
}

class _CheckoutReviewPageState extends State<CheckoutReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.initialComment;
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;
      final url = uri.toString().toLowerCase();
      if (url.contains('/payment/success') ||
          url.contains('status=approved') ||
          url.contains('payments/tamara/success')) {
        // ── Do NOT clear cart here. The backend webhook (TabbyController@webhook
        //    / TamaraController@webhook) calls cartService.clearByUserId() after
        //    it successfully captures/verifies the payment. Clearing the cart
        //    here would be premature if the webhook hasn't run yet.
        final state = context.read<CheckoutBloc>().state;
        String? orderNumber;
        if (state is CheckoutNativePaymentInit) {
          orderNumber = state.orderNumber;
        } else if (state is CheckoutRedirectToPayment) {
          orderNumber = state.orderNumber;
        }

        if (orderNumber != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => CheckoutSuccessPage(
                orderNumber: orderNumber!,
                // Payment gateway webhooks are async — poll the backend to confirm
                // payment_status == 'paid' before showing the success UI.
                requiresPolling: true,
              ),
            ),
            (route) => route.isFirst,
          );
        }
      } else if (url.contains('/payment/cancel') ||
          url.contains('/payment/fail') ||
          url.contains('status=cancel') ||
          url.contains('status=failed')) {
        _showPaymentErrorSheet(context, 'payment_declined'.tr());
      }
    });
  }

  String _getCustomerEmail(BuildContext context) {
    final accountState = context.read<AccountBloc>().state;
    if (accountState is AccountLoaded) {
      return accountState.user.email.isNotEmpty
          ? accountState.user.email
          : 'customer@example.com';
    }
    return 'customer@example.com';
  }

  @override
  void dispose() {
    _commentController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  String _normalizePhone(String rawPhone) {
    String p = rawPhone.replaceAll(RegExp(r'\s+|-'), '');
    if (p.startsWith('00966')) {
      return '+${p.substring(2)}';
    } else if (p.startsWith('0') && !p.startsWith('+')) {
      return '+966${p.substring(1)}';
    } else if (p.startsWith('966') && !p.startsWith('+')) {
      return '+$p';
    } else if (!p.startsWith('+')) {
      return '+966$p';
    }
    return p;
  }

  Future<String?> _showPhoneRequiredSheet(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: ctx.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.all(20.r),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'enter_phone_number_for_checkout'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: ctx.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'phone_number_required_for_tabby'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: 'Tajawal',
                    color: ctx.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: '5XXXXXXXX',
                    prefixIcon: Icon(Icons.phone_iphone, color: ctx.textGrey),
                    prefixText: '+966 ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'please_enter_mobile_number'.tr();
                    }
                    final clean = v.trim().replaceAll(RegExp(r'\D'), '');
                    if (clean.length < 8) {
                      return 'mobile_number_is_incorrect'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(ctx).pop(controller.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ctx.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'confirm_and_continue'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateAddressPhoneOnBackend(SavedAddressEntity address, String phone) async {
    try {
      final apiClient = di.sl<ApiClient>();
      final data = {
        'phone': phone,
        'title': address.title.isNotEmpty ? address.title : 'Home',
        'full_name': address.fullName.isNotEmpty ? address.fullName : 'Customer',
        'country': address.country.isNotEmpty ? address.country : 'SA',
        'city': address.city.isNotEmpty ? address.city : 'Riyadh',
        'zip_code': address.zipCode.isNotEmpty ? address.zipCode : '12211',
        'address': address.detailedAddress.isNotEmpty ? address.detailedAddress : 'Saudi Arabia',
        'is_default': address.isDefault ? 1 : 0,
      };

      final addressId = address.id;
      if (addressId.isNotEmpty && !addressId.startsWith('addr_')) {
        await apiClient.post(ApiEndpoints.addressUpdate(addressId), data: data);
      } else {
        await apiClient.post(ApiEndpoints.addressStore, data: data);
      }
    } catch (e) {
      developer.log('[CheckoutReview] Phone update error: $e');
    }
  }

  void _onOrderNow(BuildContext context) async {
    String phone = widget.address.phone.trim();
    if (phone.isEmpty) {
      final enteredPhone = await _showPhoneRequiredSheet(context);
      if (enteredPhone == null || enteredPhone.trim().isEmpty) return;
      phone = enteredPhone;
    }

    final normalized = _normalizePhone(phone);
    await _updateAddressPhoneOnBackend(widget.address, normalized);

    if (context.mounted) {
      context.read<CheckoutBloc>().add(CheckoutSubmitRequested({
            'address_id': widget.address.id,
            'payment_gateway': widget.paymentMethod.gatewayKey,
            'notes': _commentController.text,
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.primaryColor,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'review_the_request'.tr(),
            style: TextStyle(
              color: context.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: BlocListener<CheckoutBloc, CheckoutState>(
          listener: (context, checkoutState) async {
            if (checkoutState is CheckoutRedirectToPayment) {
              final result =
                  await Navigator.of(context).push<PaymentFlowResult>(
                MaterialPageRoute(
                  builder: (_) => PaymentWebViewPage(
                    paymentUrl: checkoutState.paymentUrl,
                    orderNumber: checkoutState.orderNumber,
                    gateway: checkoutState.gateway,
                  ),
                ),
              );
              if (!context.mounted) return;
              if (result == PaymentFlowResult.failed) {
                _showPaymentErrorSheet(context, 'payment_failed'.tr());
              }
            } else if (checkoutState is CheckoutNativePaymentInit) {
              final cartState = context.read<CartBloc>().state;
              if (cartState is! CartLoaded) return;

              final nativeService = di.sl<NativePaymentService>();
              final customerEmail = _getCustomerEmail(context);



              // ── Apple Pay ─────────────────────────────────────────────
              if (widget.paymentMethod == PaymentMethod.applePay) {
                await nativeService.startPayTabsApplePayPayment(
                  context: context,
                  orderNumber: checkoutState.orderNumber,
                  amount: cartState.total,
                  address: widget.address,
                  customerEmail: customerEmail,
                  onSuccess: (ref) async {
                    try {
                      await di.sl<ApiClient>().post(
                        ApiEndpoints.paytabsCallback,
                        options: Options(
                          contentType: 'application/json',
                          headers: {
                            'Accept': 'application/json',
                          },
                        ),
                        data: jsonEncode({
                          'tran_ref': ref,
                          'cart_id': checkoutState.orderNumber,
                          'cart_amount': cartState.total,
                          'payment_result': {
                            'response_status': 'A',
                            'response_code': '000',
                            'response_message': 'Authorized',
                          },
                        }),
                      );
                    } catch (e) {
                      developer.log('[CheckoutReviewPage] PayTabs callback failed: $e');
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => CheckoutSuccessPage(
                            orderNumber: checkoutState.orderNumber),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  onError: (error) => _showPaymentErrorSheet(context, error),
                  onCancel: () {},
                );

              // ── PayTabs Card / Mada ────────────────────────────────────
              } else {
                final isMada = widget.paymentMethod == PaymentMethod.mada;
                await nativeService.startPayTabsCardPayment(
                  context: context,
                  orderNumber: checkoutState.orderNumber,
                  amount: cartState.total,
                  address: widget.address,
                  customerEmail: customerEmail,
                  isMada: isMada,
                  onSuccess: (ref) async {
                    try {
                      await di.sl<ApiClient>().post(
                        ApiEndpoints.paytabsCallback,
                        options: Options(
                          contentType: 'application/json',
                          headers: {
                            'Accept': 'application/json',
                          },
                        ),
                        data: jsonEncode({
                          'tran_ref': ref,
                          'cart_id': checkoutState.orderNumber,
                          'cart_amount': cartState.total,
                          'payment_result': {
                            'response_status': 'A',
                            'response_code': '000',
                            'response_message': 'Authorized',
                          },
                        }),
                      );
                    } catch (e) {
                      developer.log('[CheckoutReviewPage] PayTabs callback failed: $e');
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => CheckoutSuccessPage(
                            orderNumber: checkoutState.orderNumber),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  onError: (error) => _showPaymentErrorSheet(context, error),
                  onCancel: () {},
                );
              }
            } else if (checkoutState is CheckoutSubmitted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => CheckoutSuccessPage(
                      orderNumber: checkoutState.orderNumber),
                ),
                (route) => route.isFirst,
              );
            } else if (checkoutState is CheckoutError) {
              showCustomSnackBar(
                context,
                getLocalizedError(checkoutState.message),
                isError: true,
              );
            }
          },
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded) {
                final items = state.items;
                final subtotal = state.subtotal;
                final discount = state.couponDiscount;
                final shippingFee = state.shippingCost;
                final hasFastDelivery = items.any((item) => item.options['delivery_type'] == 'fast');
                final fastDeliveryFee = hasFastDelivery ? 50.0 : 0.0;

                final total = state.total + fastDeliveryFee;
                final tax = state.taxAmount;

                return Column(
                  children: [
                    Container(
                      color: context.backgroundColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStep(context, 1, 'address'.tr(),
                              isActive: false, isCompleted: true),
                          _buildStepDivider(context, isActive: true),
                          _buildStep(context, 2, 'payment'.tr(),
                              isActive: false, isCompleted: true),
                          _buildStepDivider(context, isActive: true),
                          _buildStep(context, 3, 'review'.tr(),
                              isActive: true, isCompleted: false),
                        ],
                      ),
                    ),
                    Divider(color: context.border, height: 1.h),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                                context, 'delivery_address'.tr()),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: context.backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.primaryColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.shadowColor
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on_outlined,
                                      color: context.primaryColor, size: 22),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.address.fullName
                                                  .isNotEmpty
                                              ? widget.address.fullName
                                              : 'Name Unavailable',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          widget.address.fullAddress.isNotEmpty
                                              ? widget.address.fullAddress
                                              : 'no_address_provided'.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            _buildSectionHeader(context, 'payment_method'.tr()),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: context.backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.primaryColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.shadowColor
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.credit_card,
                                          color: context.primaryColor,
                                          size: 22),
                                      SizedBox(width: 12.w),
                                      Text(
                                        widget.paymentMethod.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                          color: context.textDark,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: context.primaryLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'active'.tr(),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryColor,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // Product listings title
                            _buildSectionHeader(
                                context, 'products_in_demand'.tr()),

                            // Product items cards
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailsPage(
                                              slug: item.slug),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: context.backgroundColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: context.primaryColor),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.shadowColor
                                                .withValues(alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              item.imageUrl,
                                              width: 70.w,
                                              height: 70.h,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                width: 70.w,
                                                height: 70.h,
                                                color: context.primaryLight,
                                                child: Icon(
                                                    Icons.shopping_bag_outlined,
                                                    color:
                                                        context.primaryColor),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: context.textDark,
                                                    fontFamily: 'Tajawal',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 6.h),
                                                Row(
                                                  children: [
                                                    ...[
                                                      Text(
                                                        '${'size_label'.tr()}: ${item.size}',
                                                        style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: context
                                                                .textGrey,
                                                            fontFamily:
                                                                'Tajawal'),
                                                      ),
                                                      SizedBox(width: 12.w),
                                                    ],
                                                    Text(
                                                      '${'quantity'.tr()}: ${item.quantity}',
                                                      style: TextStyle(
                                                          fontSize: 11.sp,
                                                          color:
                                                              context.textGrey,
                                                          fontFamily:
                                                              'Tajawal'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${(item.price * item.quantity).toStringAsFixed(1)} ﷼',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w800,
                                              color: context.primaryColor,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                              },
                            ),
                            SizedBox(height: 16.h),

                            // Order Price Breakdown Card
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: context.backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.primaryColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.shadowColor
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildSummaryRow(context, 'subtotal'.tr(),
                                      '${subtotal.toStringAsFixed(2)} ﷼'),
                                  SizedBox(height: 10.h),
                                  _buildSummaryRow(context, 'opponent'.tr(),
                                      '−${discount.toStringAsFixed(2)} ﷼',
                                      isDiscount: true),
                                  SizedBox(height: 10.h),
                                  _buildSummaryRow(
                                      context,
                                      'shipping_fees'.tr(),
                                      shippingFee == 0
                                          ? 'free'.tr()
                                          : '${shippingFee.toStringAsFixed(2)} ﷼',
                                      isFreeShipping: shippingFee == 0),
                                  if (fastDeliveryFee > 0) ...[
                                    SizedBox(height: 10.h),
                                    _buildSummaryRow(context, 'fast_shipping'.tr(),
                                        '+${fastDeliveryFee.toStringAsFixed(2)} ﷼'),
                                  ],
                                  SizedBox(height: 10.h),
                                  _buildSummaryRow(context, 'vat_15'.tr(),
                                      '${tax.toStringAsFixed(2)} ﷼'),
                                  Divider(height: 24.h, color: context.border),
                                  _buildSummaryRow(context, 'grand_total'.tr(),
                                      '${total.toStringAsFixed(2)} ﷼',
                                      isTotal: true),
                                ],
                              ),
                            ),
                            SizedBox(height: 32.h),
                          ],
                        ),
                      ),
                    ),

                    // Checkout action bottom panel
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 10,
                              offset: Offset(0, -4)),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: () => _onOrderNow(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              'order_now'.tr(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: context.backgroundColor,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0.h, left: 8.w, right: 8.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: context.textDark,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value,
      {bool isDiscount = false,
      bool isFreeShipping = false,
      bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            color: isTotal ? context.textDark : context.textMid,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 13,
            fontWeight: (isTotal || isDiscount || isFreeShipping)
                ? FontWeight.w900
                : FontWeight.bold,
            color: isDiscount
                ? context.accentColor
                : isFreeShipping
                    ? context.successColor
                    : context.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, int number, String label,
      {required bool isActive, required bool isCompleted}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22.w,
          height: 22.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? context.primaryColor
                : isActive
                    ? context.primaryColor.withValues(alpha: 0.12)
                    : context.border.withValues(alpha: 0.3),
            border: Border.all(
              color: isCompleted || isActive
                  ? context.primaryColor
                  : context.border,
              width: 1.5.w,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isActive ? context.primaryColor : context.textGrey,
                      fontFamily: 'Tajawal',
                    ),
                  ),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight:
                isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted
                ? context.primaryColor
                : context.textGrey,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(BuildContext context, {required bool isActive}) {
    return Container(
      width: 30.w,
      height: 1.5.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: isActive ? context.primaryColor : context.border,
    );
  }

  void _showPaymentErrorSheet(BuildContext context, String errorDesc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (ctx) => _PaymentErrorSheet(
        errorDesc: errorDesc,
        onRetry: () {
          Navigator.of(ctx).pop();
          _onOrderNow(context);
        },
        onChangeMethod: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop(); // Go back to payment selection
        },
      ),
    );
  }
}

class _PaymentErrorSheet extends StatefulWidget {
  final String errorDesc;
  final VoidCallback onRetry;
  final VoidCallback onChangeMethod;

  const _PaymentErrorSheet({
    required this.errorDesc,
    required this.onRetry,
    required this.onChangeMethod,
  });

  @override
  State<_PaymentErrorSheet> createState() => _PaymentErrorSheetState();
}

class _PaymentErrorSheetState extends State<_PaymentErrorSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 28.h),
            // Pulsing Error Icon
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.errorColor.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: context.errorColor,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'payment_failed'.tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              widget.errorDesc.isNotEmpty
                  ? widget.errorDesc
                  : 'payment_error'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: context.textMid,
                height: 1.6,
                fontFamily: 'Tajawal',
              ),
            ),
            SizedBox(height: 32.h),
            // Retry Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  'retry_checkout'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Change Method Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: widget.onChangeMethod,
                icon: Icon(Icons.credit_card_outlined,
                    color: context.primaryColor),
                label: Text(
                  'change_payment_method'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
