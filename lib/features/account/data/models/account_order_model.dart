import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/account_entities.dart';

class AccountOrderModel extends OrderEntity {
  const AccountOrderModel({
    required super.id,
    required super.status,
    required super.date,
    required super.time,
    required super.amount,
    required super.itemCount,
    required super.statusColorHex,
  });

  factory AccountOrderModel.fromJson(Map<String, dynamic> json) {
    // Determine status text and color based on backend status string
    String statusText = json['status'] ?? 'unknown'.tr();
    String statusColor = '#000000'; // Default black

    switch (json['status']) {
      case 'pending':
        statusText = 'on_hold'.tr();
        statusColor = '#FFB300';
        break;
      case 'processing':
        statusText = 'in_preparation'.tr();
        statusColor = '#FF9500';
        break;
      case 'shipped':
        statusText = 'delivery_is_in_progress'.tr();
        statusColor = '#2196F3';
        break;
      case 'completed':
        statusText = 'complete'.tr();
        statusColor = '#4CAF50';
        break;
      case 'cancelled':
        statusText = 'canceled'.tr();
        statusColor = '#F44336';
        break;
      case 'refunded':
        statusText = 'retrieved'.tr();
        statusColor = '#9E9E9E';
        break;
    }

    DateTime parsedDate = DateTime.now();
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at']) ?? DateTime.now();
    }

    return AccountOrderModel(
      id: json['order_number']?.toString() ?? json['id']?.toString() ?? '',
      status: statusText,
      date: parsedDate,
      time:
          '${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0'.tr())}',
      amount: _parseDouble(json['total']),
      itemCount: _parseInt(json[
          'items_count']), // backend might not return items_count in myAccount endpoint
      statusColorHex: statusColor,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
}
