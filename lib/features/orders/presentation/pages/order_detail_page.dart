import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/order_entity.dart';

// Timeline step model helper
class TrackingStep {
  final String title;
  final String time;
  final bool isCompleted;
  final bool isActive;

  const TrackingStep({
    required this.title,
    required this.time,
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

  // Mock details matching orders database
  static final OrderEntity mockOrderDetails = OrderEntity(
    id: 'o1',
    orderNumber: '#KDX-892401',
    date: '13 يونيو 2026',
    status: 'تم الشحن',
    subtotal: 35.8,
    discount: 0.0,
    shippingFee: 0.0,
    total: 50.6,
    trackingId: 'TRK-9840134',
    items: const [
      OrderItemEntity(
        id: 'oi1',
        name: 'هودي زيبر رجالي - لون رمادي مريح',
        size: 'M / رمادي',
        imageUrl: 'assets/images/cat_fashion.png',
        price: 26.8,
        quantity: 1,
      ),
      OrderItemEntity(
        id: 'oi2',
        name: 'محدل الزراع - أسود متين',
        size: 'Free / أسود',
        imageUrl: 'assets/images/cat_sports.png',
        price: 9.0,
        quantity: 1,
      ),
    ],
  );

  static final List<TrackingStep> timelineSteps = [
    const TrackingStep(title: 'تم استلام الطلب', time: '13 يونيو 2026 - 10:00 ص', isCompleted: true),
    const TrackingStep(title: 'تم التجهيز', time: '13 يونيو 2026 - 11:30 ص', isCompleted: true),
    const TrackingStep(title: 'تم الشحن', time: '13 يونيو 2026 - 02:15 م', isCompleted: true),
    const TrackingStep(title: 'في الطريق', time: '13 يونيو 2026 - 05:00 م', isCompleted: false, isActive: true),
    const TrackingStep(title: 'تم التسليم', time: '', isCompleted: false),
  ];

  @override
  Widget build(BuildContext context) {
    final order = mockOrderDetails;

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
          title: Text(
            'تفاصيل الطلب $orderNumber',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order Number & Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'طلب رقم: ${order.orderNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark, fontFamily: 'Tajawal'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'قيد التوصيل',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Tajawal'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تاريخ الطلب: ${order.date}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal'),
                    ),
                    if (order.trackingId != null) ...[
                      const Divider(height: 24, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('رقم الشحنة (التتبع)', style: TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal')),
                              const SizedBox(height: 4),
                              Text(order.trackingId!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم نسخ رقم التتبع إلى الحافظة', style: TextStyle(fontFamily: 'Tajawal'))),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('نسخ الرابط', style: TextStyle(fontSize: 11, color: AppColors.primary, fontFamily: 'Tajawal')),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Vertical Timeline Progress Tracker Card
              _buildSectionHeader('تتبع الشحنة'),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: AppColors.cardShadow,
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
                              // Step indicator dot
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: step.isCompleted
                                      ? AppColors.success
                                      : step.isActive
                                          ? AppColors.primary
                                          : Colors.white,
                                  border: Border.all(
                                    color: step.isCompleted
                                        ? AppColors.success
                                        : step.isActive
                                            ? AppColors.primary
                                            : const Color(0xFFD1D1D6),
                                    width: step.isActive ? 6 : 2,
                                  ),
                                ),
                                child: step.isCompleted
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              // Vertical connecting line
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: step.isCompleted ? AppColors.success : const Color(0xFFD1D1D6),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Step Title & Time
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: step.isCompleted || step.isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: step.isCompleted || step.isActive
                                          ? AppColors.textDark
                                          : AppColors.textGrey,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                  if (step.time.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      step.time,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textGrey,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                  ],
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
              const SizedBox(height: 16),

              // 3. Shipping Address Card
              _buildSectionHeader('عنوان التوصيل'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('محمد أحمد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Tajawal')),
                          SizedBox(height: 4),
                          Text('جوال: +966 50 123 4567', style: TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal')),
                          SizedBox(height: 2),
                          Text('شارع الملك فهد، حي النخيل، الرياض، 12345', style: TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Products List
              _buildSectionHeader('المنتجات في الشحنة'),
              ...order.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            item.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 64,
                              height: 64,
                              color: const Color(0xFFF5F5F5),
                              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textGrey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark, fontFamily: 'Tajawal'),
                              ),
                              const SizedBox(height: 4),
                              Text('المقاس: ${item.size}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal')),
                              Text('الكمية: ${item.quantity}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontFamily: 'Tajawal')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.price.toStringAsFixed(1)} ر.س',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary, fontFamily: 'Tajawal'),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),

              // 5. Price breakdown card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    _priceRow('المجموع الفرعي', '${order.subtotal.toStringAsFixed(2)} ر.س'),
                    const SizedBox(height: 10),
                    _priceRow('الخصم', '−${order.discount.toStringAsFixed(2)} ر.س', isDiscount: true),
                    const SizedBox(height: 10),
                    _priceRow('رسوم الشحن', order.shippingFee == 0 ? 'مجاني' : '${order.shippingFee.toStringAsFixed(2)} ر.س', isHighlight: order.shippingFee == 0),
                    const Divider(height: 24, color: AppColors.border),
                    _priceRow('المجموع الإجمالي', '${order.total.toStringAsFixed(2)} ر.س', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 6. Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('سيتم توجيهك لخدمة العملاء', style: TextStyle(fontFamily: 'Tajawal'))),
                        );
                      },
                      icon: const Icon(Icons.support_agent_rounded, size: 18, color: AppColors.primary),
                      label: const Text('تواصل مع الدعم', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يمكنك إرجاع السلعة من خلال سياسة الضمان', style: TextStyle(fontFamily: 'Tajawal'))),
                        );
                      },
                      icon: const Icon(Icons.assignment_return_outlined, size: 18, color: AppColors.textMid),
                      label: const Text('إرجاع السلع', style: TextStyle(fontSize: 12, color: AppColors.textMid, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 8, right: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontFamily: 'Tajawal',
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false, bool isDiscount = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.textDark : AppColors.textMid,
            fontFamily: 'Tajawal',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
            color: isDiscount
                ? AppColors.accent
                : isHighlight
                    ? AppColors.success
                    : isBold
                        ? AppColors.primary
                        : AppColors.textDark,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }
}
