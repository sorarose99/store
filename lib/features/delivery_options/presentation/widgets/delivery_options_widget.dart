import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/colors.dart';
import '../../../cart/presentation/blocs/cart_bloc.dart';
import '../../../cart/presentation/blocs/cart_event.dart';
import '../../../cart/presentation/blocs/cart_state.dart';

/// Delivery Options Widget
///
/// Reads real shipping zones from the CartBloc (already loaded from
/// the /cart backend endpoint) and wires zone selection back to
/// CartBloc → CartShippingZoneUpdated → PUT /cart/update-shipping-zone
class DeliveryOptionsWidget extends StatelessWidget {
  const DeliveryOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoaded && state.zones.isNotEmpty) {
          // Check if any item in the cart requires shipping
          final hasShippableItems = state.items.any((item) => item.requiresShipping);
          
          // If no items require shipping, only show the first zone (Free Delivery)
          // The backend expects fast delivery to be hidden/ignored for digital items.
          final displayZones = hasShippableItems 
              ? state.zones 
              : state.zones.take(1).toList();

          return _DeliveryOptionsView(
            zones: displayZones,
            selectedZoneId: state.selectedZone,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _DeliveryOptionsView extends StatelessWidget {
  final List<Map<String, dynamic>> zones;
  final int? selectedZoneId;

  const _DeliveryOptionsView({
    required this.zones,
    required this.selectedZoneId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: context.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'delivery_options_title'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.local_shipping_outlined,
                    color: context.primaryColor,
                    size: 22,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.border),

            // ── Zone list ────────────────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: zones.length > 2 ? 2 : zones.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: context.border),
              itemBuilder: (context, index) {
                final zone = zones[index];
                final zoneId = zone['id'] is int
                    ? zone['id'] as int
                    : int.tryParse(zone['id'].toString()) ?? 0;
                final isSelected = selectedZoneId == zoneId;

                return _ZoneTile(
                  zone: zone,
                  zoneId: zoneId,
                  index: index,
                  isSelected: isSelected,
                  onTap: () => context
                      .read<CartBloc>()
                      .add(CartShippingZoneUpdated(zoneId: zoneId)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  final Map<String, dynamic> zone;
  final int zoneId;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _ZoneTile({
    required this.zone,
    required this.zoneId,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  // Pull display strings from zone map — backend may use various key names
  String _title(Map<String, dynamic> z, int index) {
    if (index == 0) return 'free_shipping'.tr();
    if (index == 1) return 'fast_shipping'.tr();
    return z['name']?.toString() ??
        z['title']?.toString() ??
        z['zone_name']?.toString() ??
        z['label']?.toString() ??
        'delivery_option';
  }

  String _description(Map<String, dynamic> z, int index) {
    if (index == 0) return '${'guaranteed_delivery'.tr()}: ${'shipping_days_free'.tr()}، تقوم KDX بمتابعة مستمرة للشحنة من لحظة الإرسال وحتى التسليم خطوة بخطوة حتى وصولها بأمان';
    if (index == 1) return '${'guaranteed_delivery'.tr()}: ${'shipping_days_fast'.tr()}، تقوم KDX بمتابعة مستمرة للشحنة من لحظة الإرسال وحتى التسليم خطوة بخطوة حتى وصولها بأمان';
    return z['description']?.toString() ??
        z['details']?.toString() ??
        z['shipping_provider']?.toString() ??
        z['provider']?.toString() ??
        z['note']?.toString() ??
        '';
  }

  String _price(Map<String, dynamic> z, BuildContext context) {
    // Cover all possible backend key names for the zone fee
    final price = z['price'] ??
        z['cost'] ??
        z['amount'] ??
        z['shipping_price'] ??
        z['shipping_cost'] ??
        z['fee'];
    if (price == null) return '';
    final num p = price is num ? price : num.tryParse(price.toString()) ?? 0;
    if (p == 0) return 'free_delivery'.tr();
    return '${p.toStringAsFixed(0)} ${'sar'.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    final title = _title(zone, index);
    final description = _description(zone, index);
    final priceLabel = _price(zone, context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Radio indicator on the leading side (right in RTL) ──
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? context.primaryColor
                  : context.textGrey,
              size: 22.w,
            ),
            SizedBox(width: 12.w),
            // ── Text info ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row: name + price badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
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
                                : context.cardBackground,
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

                  // Description — gold/accent color matching screenshot
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.accent, // gold/orange accent
                        height: 1.5,
                        fontFamily: 'Tajawal',
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
  }
}
