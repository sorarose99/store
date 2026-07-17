import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/colors.dart';

class NotificationEntity {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final String type;
  final String? orderStatus;

  const NotificationEntity({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.type,
    this.orderStatus,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      title: title,
      body: body,
      time: time,
      isRead: isRead ?? this.isRead,
      type: type,
      orderStatus: orderStatus,
    );
  }

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    String? status;
    if (json['data'] is Map) {
      status = json['data']['order_status']?.toString() ?? json['data']['status']?.toString();
    }
    
    // Also try to infer status from title or body if not in data
    if (status == null) {
      final text = "${json['title']} ${json['body']}".toLowerCase();
      if (text.contains('قيد المعالجة') || text.contains('processing') || text.contains('pending')) {
        status = 'pending';
      } else if (text.contains('تم التوصيل') || text.contains('delivered') || text.contains('مكتمل') || text.contains('complete')) {
        status = 'delivered';
      } else if (text.contains('مشحون') || text.contains('shipped')) {
        status = 'shipped';
      } else if (text.contains('ملغي') || text.contains('canceled') || text.contains('cancelled')) {
        status = 'canceled';
      }
    }

    return NotificationEntity(
      title: json['title']?.toString() ?? 'إشعار',
      body: json['body']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      isRead: json['read'] == true,
      type: _typeFromData(json['data']),
      orderStatus: status,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'time': time,
        'read': isRead,
        'data': {
          'type': type,
          if (orderStatus != null) 'order_status': orderStatus,
        }
      };

  static String _typeFromData(dynamic data) {
    if (data == null) return 'system';
    if (data is Map) {
      final t = data['type']?.toString() ?? '';
      if (t.contains('order') || t.contains('ship')) return 'order';
      if (t.contains('promo') || t.contains('offer')) return 'promo';
    }
    return 'system';
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationEntity> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('local_notifications') ?? [];
    final parsed = raw.map((e) {
      try {
        return NotificationEntity.fromJson(jsonDecode(e) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<NotificationEntity>().toList();

    if (mounted) {
      setState(() {
        _notifications = parsed;
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final updated = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await prefs.setStringList(
      'local_notifications',
      updated.map((n) => jsonEncode(n.toJson())).toList(),
    );
    if (mounted) setState(() => _notifications = updated);
  }

  Future<void> _markRead(int index) async {
    if (_notifications[index].isRead) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = List<NotificationEntity>.from(_notifications);
    updated[index] = updated[index].copyWith(isRead: true);
    await prefs.setStringList(
      'local_notifications',
      updated.map((n) => jsonEncode(n.toJson())).toList(),
    );
    if (mounted) setState(() => _notifications = updated);
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
      if (diff.inDays == 1) return 'أمس';
      return 'منذ ${diff.inDays} يوم';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'الإشعارات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (unreadCount > 0)
              TextButton(
                onPressed: _markAllRead,
                child: const Text(
                  'قراءة الكل',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined,
                            size: 64, color: AppColors.textGrey.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد إشعارات',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'ستظهر هنا إشعارات طلباتك وعروضك',
                          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return _NotifCard(
                          notif: notif,
                          timeLabel: _formatTime(notif.time),
                          onTap: () => _markRead(index),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationEntity notif;
  final String timeLabel;
  final VoidCallback onTap;

  const _NotifCard({
    required this.notif,
    required this.timeLabel,
    required this.onTap,
  });
  
  List<Widget> _buildStatusBadges(BuildContext context, String status) {
    final lowerStatus = status.toLowerCase();
    
    if (lowerStatus == 'shipped' || lowerStatus == 'shipped'.tr().toLowerCase()) {
      return [
        _buildChip(
            text: 'shipped'.tr(),
            bgColor: AppColors.primary.withValues(alpha: 0.1),
            textColor: AppColors.primary),
        const SizedBox(width: 6),
        _buildChip(
            text: 'for_delivery'.tr(),
            bgColor: AppColors.primary.withValues(alpha: 0.1),
            textColor: AppColors.primary),
      ];
    } else if (lowerStatus == 'delivered' || lowerStatus == 'delivered'.tr().toLowerCase() || lowerStatus == 'complete' || lowerStatus == 'completed') {
      return [
        _buildChip(
            text: 'complete'.tr(),
            bgColor: AppColors.success.withValues(alpha: 0.1),
            textColor: AppColors.success),
        const SizedBox(width: 6),
        _buildChip(
            text: 'delivered'.tr(),
            bgColor: AppColors.success.withValues(alpha: 0.1),
            textColor: AppColors.success),
      ];
    } else if (lowerStatus == 'canceled' || lowerStatus == 'cancelled' || lowerStatus == 'canceled'.tr().toLowerCase()) {
      return [
        _buildChip(
            text: 'canceled'.tr(),
            bgColor: AppColors.error.withValues(alpha: 0.1),
            textColor: AppColors.error),
      ];
    } else if (lowerStatus == 'pending' || lowerStatus == 'processing') {
      return [
        _buildChip(
            text: 'pending'.tr(),
            bgColor: Colors.orange.withValues(alpha: 0.1),
            textColor: Colors.orange),
      ];
    }
    return [
      _buildChip(
          text: status.tr(),
          bgColor: AppColors.textGreyLight,
          textColor: AppColors.textGrey),
    ];
  }

  Widget _buildChip(
      {required String text,
      required Color bgColor,
      required Color textColor}) {
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead ? const Color(0xFFEEEEEE) : AppColors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _getColor(notif.type).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(notif.type), color: _getColor(notif.type), size: 20),
            ),
            const SizedBox(width: 12),
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
                            fontSize: 13,
                            fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
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
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notif.orderStatus != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: _buildStatusBadges(context, notif.orderStatus!),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    timeLabel,
                    style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
          ],
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

