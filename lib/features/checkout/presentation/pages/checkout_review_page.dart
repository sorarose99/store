import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdx/features/checkout/data/services/native_payment_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../features/delivery_options/presentation/widgets/delivery_options_widget.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_state.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
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
import 'package:tabby_flutter_inapp_sdk/tabby_flutter_inapp_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

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
        context.read<CartBloc>().add(const CartCleared());
        final state = context.read<CheckoutBloc>().state;
        if (state is CheckoutNativePaymentInit) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  CheckoutSuccessPage(orderNumber: state.orderNumber),
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

  void _onOrderNow(BuildContext context) {
    context.read<CheckoutBloc>().add(CheckoutSubmitRequested({
          'address_id': widget.address.id,
          'payment_gateway': widget.paymentMethod.gatewayKey,
          'notes': _commentController.text,
        }));
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
              if (result == PaymentFlowResult.failed) {
                _showPaymentErrorSheet(context, 'payment_failed'.tr());
              }
            } else if (checkoutState is CheckoutNativePaymentInit) {
              final cartState = context.read<CartBloc>().state;
              if (cartState is CartLoaded) {
                final nativeService = di.sl<NativePaymentService>();

                if (checkoutState.gateway == 'paytabs' ||
                    checkoutState.gateway == 'visa' ||
                    checkoutState.gateway == 'mada' ||
                    checkoutState.gateway == 'applepay') {
                  if (widget.paymentMethod.gatewayKey == 'applepay') {
                    await nativeService.startPayTabsApplePayPayment(
                      context: context,
                      orderNumber: checkoutState.orderNumber,
                      amount: cartState.total,
                      address: widget.address,
                      customerEmail: _getCustomerEmail(context),
                      onSuccess: (ref) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => CheckoutSuccessPage(
                                orderNumber: checkoutState.orderNumber),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      onError: (error) {
                        _showPaymentErrorSheet(context, error);
                      },
                      onCancel: () {},
                    );
                  } else {
                    await nativeService.startPayTabsCardPayment(
                      context: context,
                      orderNumber: checkoutState.orderNumber,
                      amount: cartState.total,
                      address: widget.address,
                      customerEmail: _getCustomerEmail(context),
                      isMada: widget.paymentMethod.gatewayKey == 'mada',
                      onSuccess: (ref) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => CheckoutSuccessPage(
                                orderNumber: checkoutState.orderNumber),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                      onError: (error) {
                        _showPaymentErrorSheet(context, error);
                      },
                      onCancel: () {},
                    );
                  }
                } else if (checkoutState.gateway == 'tabby') {
                  final session = await nativeService.createTabbySession(
                    orderNumber: checkoutState.orderNumber,
                    amount: cartState.total,
                    address: widget.address,
                    customerEmail: _getCustomerEmail(context),
                    items: cartState.items
                        .map((e) => CartItemEntity(
                              productId: e.productId,
                              name: e.name,
                              size: e.size,
                              color: e.color,
                              quantity: e.quantity,
                              unitPrice: e.price,
                              imageUrl: e.imageUrl,
                            ))
                        .toList(),
                  );

                  if (session != null && context.mounted) {
                    TabbyWebView.showWebView(
                      context: context,
                      webUrl:
                          session.availableProducts.installments?.webUrl ?? '',
                      onResult: (result) {
                        if (result.name == 'authorized' ||
                            result.name == 'approved') {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => CheckoutSuccessPage(
                                  orderNumber: checkoutState.orderNumber),
                            ),
                            (route) => route.isFirst,
                          );
                        } else {
                          _showPaymentErrorSheet(
                              context, 'payment_declined'.tr());
                        }
                      },
                    );
                  } else {
                    _showPaymentErrorSheet(context, 'payment_error'.tr());
                  }
                } else if (checkoutState.gateway == 'tamara') {
                  // ── Tamara: call sandbox API directly from Flutter (testing) ──
                  final checkoutUrl = await nativeService.createTamaraSession(
                    orderNumber: checkoutState.orderNumber,
                    amount: cartState.total,
                    address: widget.address,
                    customerEmail: _getCustomerEmail(context),
                    items: cartState.items
                        .map((e) => CartItemEntity(
                              productId: e.productId,
                              name: e.name,
                              size: e.size,
                              color: e.color,
                              quantity: e.quantity,
                              unitPrice: e.price,
                              imageUrl: e.imageUrl,
                            ))
                        .toList(),
                  );

                  if (checkoutUrl != null && context.mounted) {
                    // PaymentWebViewPage already detects Tamara success/cancel/fail URLs.
                    final result =
                        await Navigator.of(context).push<PaymentFlowResult>(
                      MaterialPageRoute(
                        builder: (_) => PaymentWebViewPage(
                          paymentUrl: checkoutUrl,
                          orderNumber: checkoutState.orderNumber,
                          gateway: 'tamara',
                        ),
                      ),
                    );
                    if (result == PaymentFlowResult.failed && context.mounted) {
                      _showPaymentErrorSheet(context, 'payment_failed'.tr());
                    }
                  } else {
                    if (context.mounted) {
                      // Tamara session creation failed — show a specific message
                      // guiding the user to choose another payment method.
                      _showPaymentErrorSheet(context, 'tamara_not_available'.tr());
                    }
                  }
                }
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(checkoutState.message)),
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

                final total = state.total;
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
                                          widget.address.recipientName
                                                  .isNotEmpty
                                              ? widget.address.recipientName
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

                            const DeliveryOptionsWidget(),
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
                                            '${(item.price * item.quantity).toStringAsFixed(1)} ر.س',
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
                                      '${subtotal.toStringAsFixed(2)} ر.س'),
                                  SizedBox(height: 10.h),
                                  _buildSummaryRow(context, 'opponent'.tr(),
                                      '−${discount.toStringAsFixed(2)} ر.س',
                                      isDiscount: true),
                                  SizedBox(height: 10.h),
                                  _buildSummaryRow(
                                      context,
                                      'shipping_fees'.tr(),
                                      shippingFee == 0
                                          ? 'free'.tr()
                                          : '${shippingFee.toStringAsFixed(2)} ر.س',
                                      isFreeShipping: shippingFee == 0),
                                  SizedBox(height: 10.h),
                                  _buildSummaryRow(context, 'vat_15'.tr(),
                                      '${tax.toStringAsFixed(2)} ر.س'),
                                  Divider(height: 24.h, color: context.border),
                                  _buildSummaryRow(context, 'grand_total'.tr(),
                                      '${total.toStringAsFixed(2)} ر.س',
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
