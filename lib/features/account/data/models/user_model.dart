import '../../domain/entities/account_entities.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.name,
    required super.email,
    required super.phone,
    required super.walletBalance,
    required super.ordersCount,
    required super.gender,
    required super.dateOfBirth,
    super.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['first_name']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      walletBalance: _parseDouble(json['wallet_balance']),
      ordersCount: _parseInt(json['orders_count']),
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date']) ?? DateTime.now()
          : DateTime.now(),
      avatar: json['avatar']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
