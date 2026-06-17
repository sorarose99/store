import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/order_entity.dart';
import 'order_detail_page.dart';

// Grouped order list helper structure
class OrderDateGroup {
  final String dateTitle;
  final List<OrderEntity> orders;

  const OrderDateGroup({required this.dateTitle, required this.orders});
}

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  // Comprehensive mock data that aligns with orders page specifications
  static final List<OrderDateGroup> mockGroupedOrders = [
    OrderDateGroup(
      dateTitle: 'اليوم - 13 يونيو 2026',
      orders: [
        OrderEntity(
          id: 'o1',
          orderNumber: '#KDX-892401',
          date: '2026/06/13',
          status: 'تم الشحن',
          subtotal: 26.8,
          discount: 0,
          shippingFee: 0,
          total: 50.6,
          trackingId: 'TRK-9840134',
          items: const [
            OrderItemEntity(
              id: 'oi1',
              name: 'هودي زيبر رجالي - لون رمادي مريح للغاية وملائم لفصل الشتاء',
              size: 'M',
              imageUrl: 'assets/images/cat_fashion.png',
              price: 26.8,
              quantity: 1,
            ),
            OrderItemEntity(
              id: 'oi2',
              name: 'محدل الزراع - أسود',
              size: 'Free',
              imageUrl: 'assets/images/cat_sports.png',
              price: 9.0,
              quantity: 1,
            ),
          ],
        ),
      ],
    ),
    OrderDateGroup(
      dateTitle: '10 يونيو 2026',
      orders: [
        OrderEntity(
          id: 'o2',
          orderNumber: '#KDX-891002',
          date: '2026/06/10',
          status: 'تم التسليم',
          subtotal: 199.0,
          discount: 19.0,
          shippingFee: 0,
          total: 180.0,
          items: const [
            OrderItemEntity(
              id: 'oi3',
              name: 'حذاء ركض رياضي ذو تهوية خفيفة الوزن',
              size: 'L',
              imageUrl: 'assets/images/cat_sports.png',
              price: 199.0,
              quantity: 1,
            ),
          ],
        ),
      ],
    ),
    OrderDateGroup(
      dateTitle: '20 مايو 2026',
      orders: [
        OrderEntity(
          id: 'o3',
          orderNumber: '#KDX-852099',
          date: '2026/05/20',
          status: 'ملغي',
          subtotal: 54.0,
          discount: 0,
          shippingFee: 15.0,
          total: 69.0,
          items: const [
            OrderItemEntity(
              id: 'oi4',
              name: 'عطر الفخامة العربي الفاخر للجنسين',
              size: '100ml',
              imageUrl: 'assets/images/cat_beauty.png',
              price: 54.0,
              quantity: 1,
            ),
          ],
        ),
      ],
    ),
  ];

  void _showOrderMenu(BuildContext context, OrderEntity order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'خيارات الطلب ${order.orderNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Tajawal'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                    title: const Text('عرض التفاصيل والتتبع', style: TextStyle(fontFamily: 'Tajawal')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => OrderDetailPage(orderNumber: order.orderNumber)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded, color: AppColors.primary),
                    title: const Text('تواصل مع الدعم الفني', style: TextStyle(fontFamily: 'Tajawal')),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('سيتم توجيهك للمحادثة المباشرة مع الدعم الفني', style: TextStyle(fontFamily: 'Tajawal'))),
                      );
                    },
                  ),
                  if (order.status != 'تم التسليم' && order.status != 'ملغي')
                    ListTile(
                      leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
                      title: const Text('طلب إلغاء الطلب', style: TextStyle(color: AppColors.error, fontFamily: 'Tajawal')),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إرسال طلب إلغاء المعاملة للمراجعة', style: TextStyle(fontFamily: 'Tajawal'))),
                        );
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: const Text(
            'طلباتي',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: mockGroupedOrders.length,
          itemBuilder: (context, groupIndex) {
            final group = mockGroupedOrders[groupIndex];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Group Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    group.dateTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
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
                    final mainItem = order.items.first;

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderDetailPage(orderNumber: order.orderNumber),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image Thumbnail on the Right (RTL context)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                mainItem.imageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 72,
                                  height: 72,
                                  color: const Color(0xFFF5F5F5),
                                  child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textGrey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Order Info details on the left
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'طلب رقم: ${order.orderNumber}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: AppColors.textDark,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_horiz, color: AppColors.textGrey, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _showOrderMenu(context, order),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mainItem.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMid,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'الإجمالي: ${order.total.toStringAsFixed(1)} ر.س',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.textDark,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                      // Status Badge chips
                                      Row(
                                        children: _buildStatusBadges(order.status),
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
        ),
      ),
    );
  }

  // Generate dual-status badges matching the design requirement
  List<Widget> _buildStatusBadges(String status) {
    if (status == 'تم الشحن') {
      return [
        _buildChip(text: 'تم الشحن', bgColor: const Color(0xFFE8F9F3), textColor: AppColors.success),
        const SizedBox(width: 6),
        _buildChip(text: 'للتسليم', bgColor: const Color(0xFFFFF7EC), textColor: const Color(0xFFFF9500)),
      ];
    } else if (status == 'تم التسليم') {
      return [
        _buildChip(text: 'مكتمل', bgColor: const Color(0xFFE8F9F3), textColor: AppColors.success),
        const SizedBox(width: 6),
        _buildChip(text: 'تم التسليم', bgColor: const Color(0xFFF1FCEF), textColor: Colors.green),
      ];
    } else if (status == 'ملغي') {
      return [
        _buildChip(text: 'ملغي', bgColor: const Color(0xFFFFECEB), textColor: AppColors.error),
      ];
    }
    return [
      _buildChip(text: status, bgColor: Colors.grey.shade100, textColor: AppColors.textGrey),
    ];
  }

  Widget _buildChip({required String text, required Color bgColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }
}
