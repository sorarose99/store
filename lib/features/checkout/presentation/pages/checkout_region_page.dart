import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
import '../../../cart/presentation/blocs/cart_state.dart';
import 'checkout_saved_address_page.dart';

class CheckoutRegionPage extends StatefulWidget {
  const CheckoutRegionPage({super.key});

  @override
  State<CheckoutRegionPage> createState() => _CheckoutRegionPageState();
}

class _CheckoutRegionPageState extends State<CheckoutRegionPage> {
  int? _localSelectedRegionId;

  String _price(Map<String, dynamic> z) {
    final price = z['price'] ??
        z['cost'] ??
        z['amount'] ??
        z['shipping_price'] ??
        z['shipping_cost'] ??
        z['fee'];
    if (price == null) return '';
    final num p = price is num ? price : num.tryParse(price.toString()) ?? 0;
    if (p == 0) return 'free_delivery'.tr();
    return '${p.toStringAsFixed(0)} ﷼';
  }

  void _onContinue() {
    if (_localSelectedRegionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'select_shipping_region_first'.tr(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
              fontFamily: 'Tajawal',
            ),
          ),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CheckoutSavedAddressPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          // Sync state if necessary
        }
      },
      builder: (context, state) {
        List<Map<String, dynamic>> regions = [];
        int? activeZoneId;

        if (state is CartLoaded) {
          activeZoneId = state.selectedZone;
          if (state.zones.length > 2) {
            regions = state.zones.sublist(2);
          }
        }

        if (activeZoneId != null && _localSelectedRegionId == null) {
          if (regions.any((r) => r['id'] == activeZoneId)) {
             _localSelectedRegionId = activeZoneId;
          }
        }

        return Directionality(
          textDirection: Directionality.of(context),
          child: Scaffold(
            backgroundColor: context.backgroundColor,
            appBar: AppBar(
              backgroundColor: context.surfaceColor.withValues(alpha: 0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: true,
              title: Text(
                'select_shipping_region'.tr(),
                style: TextStyle(
                  color: context.textDark,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'select_country_or_region_prompt'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textDark,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (regions.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32.h),
                        child: Text(
                          'no_additional_shipping_regions'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: context.textDark54,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: regions.length,
                        itemBuilder: (context, index) {
                          final zone = regions[index];
                          final zoneId = zone['id'] is int
                              ? zone['id'] as int
                              : int.tryParse(zone['id'].toString()) ?? 0;
          
                          final isSelected = _localSelectedRegionId == zoneId;
                          final name = zone['name']?.toString() ??
                              zone['title']?.toString() ??
                              zone['zone_name']?.toString() ??
                              'Unknown Region';
                          
                          final priceLabel = _price(zone);
          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _localSelectedRegionId = zoneId;
                              });
                              context
                                  .read<CartBloc>()
                                  .add(CartShippingZoneUpdated(zoneId: zoneId));
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.primaryColor.withValues(alpha: 0.1)
                                    : context.surfaceColor,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected
                                      ? context.primaryColor
                                      : context.primaryColor.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: context.primaryColor.withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color: context.shadowColor.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? context.primaryColor
                                        : context.textGrey,
                                    size: 22.w,
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: context.textDark,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                        ),
                                        if (priceLabel.isNotEmpty) ...[
                                          SizedBox(width: 8.w),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? context.primaryColor
                                                      .withValues(alpha: 0.12)
                                                  : context.backgroundColor,
                                              borderRadius: BorderRadius.circular(6.r),
                                            ),
                                            child: Text(
                                              priceLabel,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? context.primaryColor
                                                    : context.textGrey,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'continue_action'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
