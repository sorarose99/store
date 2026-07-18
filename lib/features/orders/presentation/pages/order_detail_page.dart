import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/order_entity.dart';
import '../blocs/orders_bloc.dart';
import '../blocs/orders_event.dart';
import '../blocs/orders_state.dart';
import '../../../../core/widgets/app_shimmer.dart';

// Timeline step model helper
class TrackingStep {
  final String title;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  TrackingStep({
    required this.title,
    required this.icon,
    required this.isCompleted,
    this.isActive = false,
  });
}

class OrderDetailPage extends StatelessWidget {
  final String orderNumber;

  const OrderDetailPage({
    super.key,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersBloc>()..add(OrderDetailRequested(orderNumber:orderNumber)),
      child: _OrderDetailContentView(orderNumber: orderNumber),
    );
  }
}

class _OrderDetailContentView extends StatelessWidget {
  final String orderNumber;

  const _OrderDetailContentView({
    required this.orderNumber,
  });

  String _getStepTranslation(String key) {
    switch (key) {
      case 'order': return 'the_request_has_been'.tr();
      case 'payment': return 'payment'.tr();
      case 'pending': return 'pending'.tr();
      case 'processing': return 'prepared'.tr();
      case 'shipped': return 'shipped'.tr();
      case 'completed':
      case 'delivered': return 'delivered'.tr();
      default: return key.tr();
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fa-check': return Icons.shopping_cart_checkout;
      case 'fa-money-bill': return Icons.payment;
      case 'fa-hourglass-half': return Icons.hourglass_bottom;
      case 'fa-spinner': return Icons.storefront;
      case 'fa-truck': return Icons.local_shipping;
      case 'fa-check-circle': return Icons.thumb_up_alt_outlined;
      default: return Icons.radio_button_checked;
    }
  }

  List<TrackingStep> _buildTimeline(OrderEntity order) {
    List<String> stepKeys = [];
    if (order.trackingSteps != null && order.trackingSteps is Map) {
      stepKeys = (order.trackingSteps as Map).keys.map((e) => e.toString()).toList();
    } else {
      stepKeys = ['order', 'processing', 'shipped', 'completed'];
    }

    String currentStatus = order.status.toLowerCase();
    if (currentStatus == 'delivered') currentStatus = 'completed';

    int currentIndex = stepKeys.indexOf(currentStatus);
    if (currentIndex == -1 && currentStatus != 'cancelled' && currentStatus != 'canceled') {
      currentIndex = 0; // fallback if unknown status
    }

    List<TrackingStep> timeline = [];
    for (int i = 0; i < stepKeys.length; i++) {
      String key = stepKeys[i];
      bool isCompleted = (currentStatus != 'cancelled' && currentStatus != 'canceled') && i <= currentIndex;
      bool isActive = (currentStatus != 'cancelled' && currentStatus != 'canceled') && i == currentIndex;

      String iconName = '';
      if (order.trackingIcons != null && order.trackingIcons is Map) {
        iconName = (order.trackingIcons as Map)[key]?.toString() ?? '';
      }

      timeline.add(TrackingStep(
        title: _getStepTranslation(key),
        icon: _getIconData(iconName),
        isCompleted: isCompleted,
        isActive: isActive,
      ));
    }
    return timeline;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'تفاصيل الطلب $orderNumber',
            style: TextStyle(
              color: context.textDark,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: BlocListener<OrdersBloc, OrdersState>(
          listener: (context, state) async {
            if (state is OrderActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Tajawal'))),
              );
              // Refresh order details
              context.read<OrdersBloc>().add(OrderDetailRequested(orderNumber: orderNumber));
            } else if (state is OrderActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Tajawal'))),
              );
            } else if (state is OrderInvoiceLoaded) {
              final url = Uri.parse(state.invoiceUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('could_not_launch_url'.tr(), style: const TextStyle(fontFamily: 'Tajawal'))),
                  );
                }
              }
            }
          },
          child: BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              if (state is OrdersLoading || state is OrdersInitial || state is OrderActionLoading) {
                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: 4,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: 16.0.h),
                    child: AppShimmer(
                        width: double.infinity, height: 120.h, borderRadius: 16),
                  ),
                );
              } else if (state is OrdersError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: context.errorColor, size: 48),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        style: TextStyle(color: context.textDark, fontSize: 16.sp, fontFamily: 'Tajawal'),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => context.read<OrdersBloc>().add(OrderDetailRequested(orderNumber: orderNumber)),
                        style: ElevatedButton.styleFrom(backgroundColor: context.primaryColor),
                        child: Text('try_again'.tr(), style: TextStyle(color: context.backgroundColor, fontFamily: 'Tajawal')),
                      ),
                    ],
                  ),
                );
              } else if (state is OrderDetailLoaded) {
              final order = state.order;
              final timelineSteps = _buildTimeline(order);

              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Order Number & Status Card
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.border, width: 0.8.w),
                        boxShadow: [
                          BoxShadow(
                            color: context.shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'طلب رقم: ${order.orderNumber}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.sp,
                                      color: context.textDark,
                                      fontFamily: 'Tajawal'),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: context.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getStepTranslation(order.status),
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryColor,
                                      fontFamily: 'Tajawal'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'تاريخ الطلب: ${order.date}',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: context.textGrey,
                                fontFamily: 'Tajawal'),
                          ),
                          if (order.trackingId != null && order.trackingId!.isNotEmpty) ...[
                            Divider(height: 24.h, color: context.border),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('shipment_number_tracking'.tr(),
                                        style: TextStyle(
                                            fontSize: 11.sp,
                                            color: context.textGrey,
                                            fontFamily: 'Tajawal')),
                                    SizedBox(height: 4.h),
                                    Text(order.trackingId!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.sp,
                                            color: context.textDark)),
                                  ],
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'the_tracking_number_has'.tr(),
                                              style:
                                                  const TextStyle(fontFamily: 'Tajawal'))),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: context.primaryColor),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text('copy_link'.tr(),
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: context.primaryColor,
                                          fontFamily: 'Tajawal')),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 2. Vertical Timeline Progress Tracker Card
                    if (timelineSteps.isNotEmpty) ...[
                      _buildSectionHeader(context, 'shipment_tracking'.tr()),
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.border, width: 0.8.w),
                          boxShadow: [
                          BoxShadow(
                            color: context.shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: timelineSteps.length,
                          itemBuilder: (context, index) {
                            final step = timelineSteps[index];
                            final isLast = index == timelineSteps.length - 1;

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left indicator: circle and vertical line
                                  Column(
                                    children: [
                                      // Step indicator icon circle
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        width: 44.w,
                                        height: 44.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: step.isCompleted || step.isActive
                                              ? context.primaryColor
                                              : context.backgroundColor,
                                          border: step.isCompleted || step.isActive
                                              ? null
                                              : Border.all(color: context.border, width: 2),
                                        ),
                                        child: Icon(
                                          step.icon,
                                          size: 20.sp,
                                          color: step.isCompleted || step.isActive
                                              ? context.backgroundColor
                                              : context.textMid,
                                        ),
                                      ),
                                      // Vertical connecting line
                                      if (!isLast)
                                        Container(
                                          width: 2.w,
                                          height: 30.h,
                                          margin: EdgeInsets.symmetric(vertical: 4.h),
                                          color: step.isCompleted
                                              ? context.primaryColor
                                              : context.border,
                                        ),
                                    ],
                                  ),
                                  SizedBox(width: 16.w),

                                  // Step Title
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 12.0.h, bottom: !isLast ? 30.0.h : 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            step.title,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight:
                                                  step.isCompleted || step.isActive
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                              color: step.isCompleted || step.isActive
                                                  ? context.textDark
                                                  : context.textMid,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // 3. Shipping Address Card
                    if (order.shippingFullName != null) ...[
                      _buildSectionHeader(context, 'delivery_address'.tr()),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.border, width: 0.8.w),
                          boxShadow: [
                          BoxShadow(
                            color: context.shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: context.primaryColor, size: 22),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order.shippingFullName ?? '',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                      )),
                                  SizedBox(height: 4.h),
                                  Text(order.shippingPhone ?? '',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      )),
                                  SizedBox(height: 2.h),
                                  Text(order.shippingAddress ?? '',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // 4. Products List
                    if (order.items.isNotEmpty) ...[
                      _buildSectionHeader(context, 'products_in_shipment'.tr()),
                      ...order.items.map((item) => Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: context.backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.border, width: 0.8.w),
                              boxShadow: [
                          BoxShadow(
                            color: context.shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item.imageUrl,
                                    width: 64.w,
                                    height: 64.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 64.w,
                                      height: 64.h,
                                      color: context.primaryLight,
                                      child: Icon(Icons.shopping_bag_outlined,
                                          color: context.primaryColor),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.sp,
                                            color: context.textDark,
                                            fontFamily: 'Tajawal'),
                                      ),
                                      if (item.size != null && item.size!.isNotEmpty) ...[
                                        SizedBox(height: 4.h),
                                        Text('المقاس: ${item.size}',
                                            style: TextStyle(
                                                fontSize: 11.sp,
                                                color: context.textGrey,
                                                fontFamily: 'Tajawal')),
                                      ],
                                      SizedBox(height: 2.h),
                                      Text('الكمية: ${item.quantity}',
                                          style: TextStyle(
                                              fontSize: 11.sp,
                                              color: context.textGrey,
                                              fontFamily: 'Tajawal')),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${item.price.toStringAsFixed(1)} ﷼',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.sp,
                                          color: context.primaryColor,
                                          fontFamily: 'Tajawal'),
                                    ),
                                    if (order.status == 'completed' || order.status == 'delivered') ...[
                                      SizedBox(height: 8.h),
                                      InkWell(
                                        onTap: () => _showReviewBottomSheet(context, order.id, item),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: context.accentColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: context.accentColor),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.star_border, size: 14.sp, color: context.accentColor),
                                              SizedBox(width: 4.w),
                                              Text(
                                                'rate_product'.tr(),
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: context.accentColor,
                                                  fontFamily: 'Tajawal',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          )),
                      SizedBox(height: 16.h),
                    ],

                    // 5. Price breakdown card
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.border, width: 0.8.w),
                        boxShadow: [
                          BoxShadow(
                            color: context.shadowColor.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _priceRow(context, 'subtotal'.tr(),
                              '${order.subtotal.toStringAsFixed(2)} ﷼'),
                          SizedBox(height: 10.h),
                          _priceRow(context, 'opponent'.tr(),
                              '−${order.discount.toStringAsFixed(2)} ﷼',
                              isDiscount: true),
                          SizedBox(height: 10.h),
                          _priceRow(
                              context,
                              'shipping_fees'.tr(),
                              order.shippingFee == 0
                                  ? 'free'.tr()
                                  : '${order.shippingFee.toStringAsFixed(2)} ﷼',
                              isHighlight: order.shippingFee == 0),
                          Divider(height: 24.h, color: context.border),
                          _priceRow(context, 'grand_total'.tr(),
                              '${order.total.toStringAsFixed(2)} ﷼',
                              isBold: true),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // 6. Action buttons
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  context.read<OrdersBloc>().add(OrderInvoiceRequested(orderNumber: order.orderNumber));
                                },
                                icon: Icon(Icons.receipt_long_outlined,
                                    size: 18, color: context.primaryColor),
                                label: Text('download_invoice'.tr(),
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: context.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal')),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  side: BorderSide(
                                      color: context.primaryColor, width: 1.5.w),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            if (order.status == 'pending' || order.status == 'processing') ...[
                              SizedBox(width: 12.w),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showCancelDialog(context, order),
                                  icon: Icon(Icons.cancel_outlined,
                                      size: 18, color: context.errorColor),
                                  label: Text('cancel_order'.tr(),
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: context.errorColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Tajawal')),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 14.h),
                                    side: BorderSide(
                                        color: context.errorColor, width: 1.5.w),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('you_will_be_directed'.tr(),
                                            style: const TextStyle(fontFamily: 'Tajawal'))),
                                  );
                                },
                                icon: Icon(Icons.support_agent_rounded,
                                    size: 18, color: context.textMid),
                                label: Text('contact_support'.tr(),
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: context.textMid,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal')),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  side: BorderSide(
                                      color: context.border, width: 1.5.w),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('you_can_return_the'.tr(),
                                            style: const TextStyle(fontFamily: 'Tajawal'))),
                                  );
                                },
                                icon: Icon(Icons.assignment_return_outlined,
                                    size: 18, color: context.textMid),
                                label: Text('return_goods'.tr(),
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: context.textMid,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Tajawal')),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  side: BorderSide(color: context.border, width: 1.5.w),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
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

  Widget _priceRow(BuildContext context, String label, String value,
      {bool isBold = false,
      bool isDiscount = false,
      bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? context.textDark : context.textMid,
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
            color: isDiscount
                ? context.accentColor
                : isHighlight
                    ? context.successColor
                    : isBold
                        ? context.primaryColor
                        : context.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'cancel_order'.tr(),
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, color: context.errorColor),
            ),
            content: Text(
              'are_you_sure_you_want_to_cancel'.tr(),
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('cancel'.tr(), style: const TextStyle(fontFamily: 'Tajawal')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<OrdersBloc>().add(OrderCancelRequested(orderId: order.id));
                },
                style: ElevatedButton.styleFrom(backgroundColor: context.errorColor),
                child: Text('confirm'.tr(), style: TextStyle(color: context.backgroundColor, fontFamily: 'Tajawal')),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReviewBottomSheet(BuildContext context, String orderId, OrderItemEntity item) {
    int currentRating = 5;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
                  left: 20.w,
                  right: 20.w,
                  top: 20.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'rate_product'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textDark,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50.w,
                              height: 50.h,
                              color: context.primaryLight,
                              child: Icon(Icons.shopping_bag_outlined, color: context.primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                              color: context.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < currentRating ? Icons.star : Icons.star_border,
                            color: context.accentColor,
                            size: 32.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              currentRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'write_your_review'.tr(),
                        hintStyle: TextStyle(fontFamily: 'Tajawal', color: context.textGrey, fontSize: 13.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: context.primaryColor),
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Tajawal'),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop();
                          context.read<OrdersBloc>().add(
                            OrderReviewSubmitted(
                              orderId: orderId,
                              productId: item.productId,
                              rating: currentRating,
                              comment: commentController.text,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'submit_review'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: context.backgroundColor,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
