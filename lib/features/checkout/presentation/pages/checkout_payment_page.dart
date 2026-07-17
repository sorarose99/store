import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/checkout_entities.dart';
import '../blocs/checkout_bloc.dart';
import 'checkout_review_page.dart';

// ── 7 Payment Methods as required ──────────────────────────────────────────
enum PaymentMethod {
  applePay,
  mada,
  paytabs,
  maestro,
  mastercard,
  tamara,
  tabby;

  static const List<PaymentMethod> checkoutOptions = [
    PaymentMethod.tabby,
    PaymentMethod.tamara,
    PaymentMethod.paytabs,
  ];

  static PaymentMethod? fromString(String gateway) {
    switch (gateway.toLowerCase()) {
      case 'applepay':
      case 'apple_pay':
      case 'apple pay':
        return PaymentMethod.applePay;
      case 'mada':
        return PaymentMethod.mada;
      case 'visa':
      case 'paytabs':
        return PaymentMethod.paytabs;
      case 'tamara':
        return PaymentMethod.tamara;
      case 'tabby':
        return PaymentMethod.tabby;
      case 'maestro':
        return PaymentMethod.maestro;
      case 'mastercard':
        return PaymentMethod.mastercard;
      default:
        return null;
    }
  }
}

extension PaymentMethodExt on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.mada:
        return 'mada_card'.tr();
      case PaymentMethod.paytabs:
        return 'KDX';
      case PaymentMethod.maestro:
        return 'Maestro';
      case PaymentMethod.mastercard:
        return 'MasterCard';
      case PaymentMethod.tamara:
        return 'tamara'.tr();
      case PaymentMethod.tabby:
        return 'tabby'.tr();
    }
  }

  String get badgeText {
    switch (this) {
      case PaymentMethod.applePay:
        return ' Pay';
      case PaymentMethod.mada:
        return 'mada';
      case PaymentMethod.paytabs:
        return 'KDX';
      case PaymentMethod.maestro:
        return 'Maestro';
      case PaymentMethod.mastercard:
        return 'MC';
      case PaymentMethod.tamara:
        return 'tamara';
      case PaymentMethod.tabby:
        return 'tabby';
    }
  }

  Color badgeBg(BuildContext context) {
    switch (this) {
      case PaymentMethod.applePay:
        return context.textDark;
      case PaymentMethod.mada:
        return context.primaryColor;
      case PaymentMethod.paytabs:
        return context.primaryColor;
      case PaymentMethod.maestro:
        return context.primaryColor;
      case PaymentMethod.mastercard:
        return context.primaryColor;
      case PaymentMethod.tamara:
        return context.primaryColor;
      case PaymentMethod.tabby:
        return context.primaryColor;
    }
  }

  Color badgeFg(BuildContext context) {
    switch (this) {
      case PaymentMethod.tabby:
        return context.textDark;
      default:
        return context.backgroundColor;
    }
  }

  bool get isBNPL =>
      this == PaymentMethod.tamara || this == PaymentMethod.tabby;
  bool get needsCardForm =>
      this == PaymentMethod.paytabs ||
      this == PaymentMethod.maestro ||
      this == PaymentMethod.mastercard ||
      this == PaymentMethod.mada;

  /// Backend `payment_gateway` value for POST /orders
  String get gatewayKey {
    switch (this) {
      case PaymentMethod.tabby:
        return 'tabby';
      case PaymentMethod.tamara:
        return 'tamara';
      default:
        return 'paytabs';
    }
  }
}

class CheckoutPaymentPage extends StatefulWidget {
  final SavedAddressEntity address;
  final List<String> activeGateways;

  const CheckoutPaymentPage({
    super.key, 
    required this.address,
    required this.activeGateways,
  });

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  late List<PaymentMethod> _availableMethods;
  PaymentMethod _selectedMethod = PaymentMethod.mada;

  @override
  void initState() {
    super.initState();
    _availableMethods = _getAvailableMethods();
    if (_availableMethods.isNotEmpty) {
      _selectedMethod = _availableMethods.first;
    }
  }

  List<PaymentMethod> _getAvailableMethods() {
    if (widget.activeGateways.isEmpty) {
      return PaymentMethod.checkoutOptions;
    }
    
    final activeMethods = <PaymentMethod>{};
    for (var gw in widget.activeGateways) {
      final m = PaymentMethod.fromString(gw);
      if (m != null) activeMethods.add(m);
    }

    return PaymentMethod.checkoutOptions.where((m) => activeMethods.contains(m)).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<CheckoutBloc>(),
          child: CheckoutReviewPage(
            address: widget.address,
            paymentMethod: _selectedMethod,
          ),
        ),
      ),
    );
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
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'payment_method'.tr(),
            style: TextStyle(
              color: context.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: Column(
          children: [
            // Breadcrumb steps
            Container(
              color: context.backgroundColor,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'address'.tr(),
                      isActive: false, isCompleted: true),
                  _buildStepDivider(isActive: true),
                  _buildStep(2, 'payment'.tr(),
                      isActive: true, isCompleted: false),
                  _buildStepDivider(isActive: false),
                  _buildStep(3, 'review'.tr(),
                      isActive: false, isCompleted: false),
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
                    // ── Payment Methods List ─────────────────────────────────
                    ...PaymentMethod.checkoutOptions
                        .map((method) => _buildMethodRow(context, method)),

                    // Removed raw credit card inputs as payment gateways handle this directly

                    // BNPL info snippet
                    if (_selectedMethod.isBNPL) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: _selectedMethod
                              .badgeBg(context)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _selectedMethod
                                  .badgeBg(context)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: _selectedMethod.badgeBg(context),
                                size: 18),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                _selectedMethod == PaymentMethod.tamara
                                    ? 'pay_in_3_interestfree'.tr()
                                    : 'pay_in_4_interestfree'.tr(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: _selectedMethod.badgeBg(context),
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // معلومات التواصل tile
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward_ios,
                                color: context.textGrey, size: 14),
                            SizedBox(width: 12.w),
                            Text(
                              'contact_information'.tr(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textDark,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // Sticky bottom bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                  child: ElevatedButton.icon(
                    onPressed: _onContinue,
                    icon: _selectedMethod == PaymentMethod.applePay
                        ? Icon(Icons.apple,
                            color: context.backgroundColor, size: 20)
                        : Icon(Icons.lock_outline_rounded,
                            color: context.backgroundColor, size: 18),
                    label: Text(
                      'المتابعة / ${_selectedMethod.label}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: context.backgroundColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedMethod.badgeBg(context),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodRow(BuildContext context, PaymentMethod method) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
                  ? method.badgeBg(context).withValues(alpha: 0.06)
                  : context.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? method.badgeBg(context) : context.primaryColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: method.badgeBg(context).withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ]
              : AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Radio dot
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                          ? method.badgeBg(context)
                          : context.primaryColor,
                  width: isSelected ? 6 : 2,
                ),
                color: context.backgroundColor,
              ),
            ),
            SizedBox(width: 14.w),
            // Label
            Expanded(
              child: Text(
                method.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isSelected ? context.textDark : context.textMid,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            // Branded badge
            if (method == PaymentMethod.paytabs)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 22.h,
                ),
              )
            else if (method == PaymentMethod.tabby)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: method.badgeBg(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.network(
                  'https://www.google.com/s2/favicons?domain=tabby.ai&sz=128',
                  height: 22.h,
                  errorBuilder: (c, o, s) => Text(
                    method.badgeText,
                    style: TextStyle(
                      color: method.badgeFg(context),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else if (method == PaymentMethod.tamara)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: method.badgeBg(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Image.network(
                  'https://www.google.com/s2/favicons?domain=tamara.co&sz=128',
                  height: 22.h,
                  errorBuilder: (c, o, s) => Text(
                    method.badgeText,
                    style: TextStyle(
                      color: method.badgeFg(context),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: method.badgeBg(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  method.badgeText,
                  style: TextStyle(
                    color: method.badgeFg(context),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }



  Widget _buildStep(int number, String label,
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
                    ? context.primaryColor.withValues(alpha: 0.1)
                    : context.cardBackground,
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
                      color: isActive
                          ? context.primaryColor
                          : context.textGrey,
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

  Widget _buildStepDivider({required bool isActive}) {
    return Container(
      width: 30.w,
      height: 1.5.h,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: isActive ? context.primaryColor : context.border,
    );
  }
}
