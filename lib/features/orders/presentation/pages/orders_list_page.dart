import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/order_entity.dart';
import '../blocs/orders_bloc.dart';
import '../blocs/orders_event.dart';
import '../blocs/orders_state.dart';
import 'order_detail_page.dart';
import '../../../../core/widgets/app_shimmer.dart';

// Grouped order list helper structure
class OrderDateGroup {
  final String dateTitle;
  final List<OrderEntity> orders;

  OrderDateGroup({required this.dateTitle, required this.orders});
}

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersBloc>()..add(const OrdersRequested()),
      child: const _OrdersListContentView(),
    );
  }
}

class _OrdersListContentView extends StatelessWidget {
  const _OrdersListContentView();

  void _showOrderMenu(BuildContext context, OrderEntity order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: Directionality.of(context),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: context.textGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'خيارات الطلب ${order.orderNumber}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                        fontFamily: 'Tajawal'),
                  ),
                  SizedBox(height: 12.h),
                  ListTile(
                    leading: Icon(Icons.receipt_long_outlined,
                        color: context.primaryColor),
                    title: Text('view_details_and_tracking'.tr(),
                        style: const TextStyle(fontFamily: 'Tajawal')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => OrderDetailPage(
                                orderNumber: order.orderNumber)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.support_agent_rounded,
                        color: context.primaryColor),
                    title: Text('contact_technical_support'.tr(),
                        style: const TextStyle(fontFamily: 'Tajawal')),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('you_will_be_directed_1'.tr(),
                                style: const TextStyle(fontFamily: 'Tajawal'))),
                      );
                    },
                  ),
                  if (order.status != 'delivered'.tr() &&
                      order.status != 'canceled'.tr() &&
                      order.status != 'Cancelled')
                    ListTile(
                      leading: Icon(Icons.cancel_outlined,
                          color: context.errorColor),
                      title: Text('request_to_cancel_the'.tr(),
                          style: TextStyle(
                              color: context.errorColor,
                              fontFamily: 'Tajawal')),
                      onTap: () {
                        Navigator.pop(context);
                        context
                            .read<OrdersBloc>()
                            .add(OrderCancelRequested(orderId: order.id));
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<OrderDateGroup> _groupOrders(List<OrderEntity> orders) {
    final Map<String, List<OrderEntity>> map = {};
    for (var order in orders) {
      map.putIfAbsent(order.date, () => []).add(order);
    }
    return map.entries
        .map((e) => OrderDateGroup(dateTitle: e.key, orders: e.value))
        .toList();
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
            'my_orders'.tr(),
            style: TextStyle(
              color: context.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: BlocConsumer<OrdersBloc, OrdersState>(
          listener: (context, state) {
            if (state is OrderActionSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              context.read<OrdersBloc>().add(const OrdersRequested());
            } else if (state is OrderActionError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is OrdersLoading ||
                state is OrdersInitial ||
                state is OrderActionLoading) {
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: 16.0.h),
                  child: AppShimmer(
                      width: double.infinity, height: 100.h, borderRadius: 12),
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
                      onPressed: () => context.read<OrdersBloc>().add(const OrdersRequested()),
                      style: ElevatedButton.styleFrom(backgroundColor: context.primaryColor),
                      child: Text('try_again'.tr(), style: TextStyle(color: context.backgroundColor, fontFamily: 'Tajawal')),
                    ),
                  ],
                ),
              );
            } else if (state is OrdersLoaded) {
              if (state.orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: context.textGreyLight),
                      SizedBox(height: 16.h),
                      Text(
                        'there_are_no_requests'.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: context.textMid,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                );
              }
              final groupedOrders = _groupOrders(state.orders);
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                itemCount: groupedOrders.length,
                itemBuilder: (context, groupIndex) {
                  final group = groupedOrders[groupIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Group Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          group.dateTitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textGrey,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),

                      // Orders in this group
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: group.orders.length,
                        itemBuilder: (context, orderIndex) {
                          final order = group.orders[orderIndex];
                          final mainItem =
                              order.items.isNotEmpty ? order.items.first : null;

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailPage(
                                      orderNumber: order.orderNumber),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 6.h),
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: context.backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.border, width: 0.8.w),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image Thumbnail on the Right (RTL context)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      mainItem?.imageUrl ?? '',
                                      width: 72.w,
                                      height: 72.h,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 72.w,
                                        height: 72.h,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        child: Icon(Icons.shopping_bag_outlined,
                                            color: context.textGrey),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),

                                  // Order Info details on the left
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'طلب رقم: ${order.orderNumber}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13.sp,
                                                  color: context.textDark,
                                                  fontFamily: 'Tajawal',
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.more_horiz,
                                                  color: context.textGrey,
                                                  size: 20),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () => _showOrderMenu(
                                                  context, order),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          mainItem?.name ??
                                              'order_without_products'.tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: context.textMid,
                                            fontFamily: 'Tajawal',
                                          ),
                                        ),
                                        SizedBox(height: 6.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${'total'.tr()}: ${order.total.toStringAsFixed(1)} ر.س',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp,
                                                color: context.textDark,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                            // Status Badge chips
                                            Row(
                                              children: _buildStatusBadges(
                                                  context, order.status),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Generate dual-status badges matching the design requirement
  List<Widget> _buildStatusBadges(BuildContext context, String status) {
    if (status == 'shipped'.tr()) {
      return [
        _buildChip(
            text: 'shipped'.tr(),
            bgColor: context.primaryColor.withValues(alpha: 0.1),
            textColor: context.primaryColor),
        SizedBox(width: 6.w),
        _buildChip(
            text: 'for_delivery'.tr(),
            bgColor: context.primaryColor.withValues(alpha: 0.1),
            textColor: context.primaryColor),
      ];
    } else if (status == 'delivered'.tr()) {
      return [
        _buildChip(
            text: 'complete'.tr(),
            bgColor: context.successColor.withValues(alpha: 0.1),
            textColor: context.successColor),
        SizedBox(width: 6.w),
        _buildChip(
            text: 'delivered'.tr(),
            bgColor: context.successColor.withValues(alpha: 0.1),
            textColor: context.successColor),
      ];
    } else if (status == 'canceled'.tr()) {
      return [
        _buildChip(
            text: 'canceled'.tr(),
            bgColor: context.errorColor.withValues(alpha: 0.1),
            textColor: context.errorColor),
      ];
    }
    return [
      _buildChip(
          text: status,
          bgColor: context.textGreyLight,
          textColor: context.textGrey),
    ];
  }

  Widget _buildChip(
      {required String text,
      required Color bgColor,
      required Color textColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }
}
