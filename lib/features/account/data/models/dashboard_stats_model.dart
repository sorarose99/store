import '../../domain/entities/account_entities.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.totalOrders,
    required super.pendingOrders,
    required super.processingOrders,
    required super.completedOrders,
    required super.wishlistCount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalOrders: _parseInt(json['total_orders']),
      pendingOrders: _parseInt(json['pending_orders']),
      processingOrders: _parseInt(json['processing_orders']),
      completedOrders: _parseInt(json['completed_orders']),
      wishlistCount: _parseInt(json['wishlist_count']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
