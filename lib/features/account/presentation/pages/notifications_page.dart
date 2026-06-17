import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String date;
  final bool isRead;
  final String type; // 'promo', 'order', 'system'

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.isRead,
    required this.type,
  });
}

const _mockNotifications = [
  NotificationEntity(
    id: '1',
    title: 'تهانينا! تم قبول طلب الترويج الخاص بك',
    body: 'مرحباً، تم قبول الترويج والربح الخاص بك بنجاح. يمكنك الآن البدء في مشاركة الروابط وجني الأرباح.',
    date: '10 أكتوبر 2023 | 12:30 م',
    isRead: false,
    type: 'promo',
  ),
  NotificationEntity(
    id: '2',
    title: 'تحديث الشحنة لطلبك #221859',
    body: 'تم تسليم شحنتك لشركة التوصيل وهي الآن في طريقها إليك. يمكنك تتبع الشحنة لمعرفة الوقت المتوقع للتسليم.',
    date: '09 أكتوبر 2023 | 04:15 م',
    isRead: false,
    type: 'order',
  ),
  NotificationEntity(
    id: '3',
    title: 'عرض خاص لليوم الوطني 🇸🇦',
    body: 'استخدم كود خصم SA2024 واحصل على تخفيض يصل إلى 30% على كافة المنتجات والأزياء الراقية.',
    date: '05 أكتوبر 2023 | 09:00 ص',
    isRead: true,
    type: 'promo',
  ),
  NotificationEntity(
    id: '4',
    title: 'تأكيد عملية السحب بنجاح',
    body: 'لقد تم تحويل مبلغ 575.00 ر.س بنجاح إلى حسابك المصرفي المسجل. تستغرق العملية عادةً من 1-3 أيام عمل.',
    date: '01 أكتوبر 2023 | 11:20 ص',
    isRead: true,
    type: 'system',
  ),
];

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'الإشعارات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _mockNotifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
          itemBuilder: (context, index) {
            final notif = _mockNotifications[index];
            return InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon/Avatar representing status
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getBgColor(notif.type),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(notif.type),
                        color: _getColor(notif.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Body text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              if (!notif.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.body,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textGrey,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif.date,
                            style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
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
      ),
    );
  }

  Color _getColor(String type) {
    switch (type) {
      case 'promo':
        return Colors.orange;
      case 'order':
        return AppColors.primary;
      default:
        return const Color(0xFF2ECC71);
    }
  }

  Color _getBgColor(String type) {
    return _getColor(type).withOpacity(0.08);
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'promo':
        return Icons.local_offer_outlined;
      case 'order':
        return Icons.local_shipping_outlined;
      default:
        return Icons.notifications_none;
    }
  }
}
