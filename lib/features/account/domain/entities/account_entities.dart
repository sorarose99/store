import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String name;
  final String email;
  final String phone;
  final double walletBalance;
  final int ordersCount;
  final String gender;
  final DateTime dateOfBirth;

  const UserEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.walletBalance,
    required this.ordersCount,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  List<Object?> get props => [name, email, phone, walletBalance, ordersCount, gender, dateOfBirth];
}

class OrderEntity extends Equatable {
  final String id;
  final String status; // e.g. "شحن المحطة الإلكترونية"
  final DateTime date; // e.g. 19 أكتوبر 2023 
  final String time; // e.g. 10:00 صباحاً
  final double amount;
  final int itemCount;
  final String statusColorHex; // e.g. #00BFA5

  const OrderEntity({
    required this.id,
    required this.status,
    required this.date,
    required this.time,
    required this.amount,
    required this.itemCount,
    required this.statusColorHex,
  });

  @override
  List<Object?> get props => [id, status, date, time, amount, itemCount, statusColorHex];
}

class CouponEntity extends Equatable {
  final String code;
  final String title;
  final String subtitle;
  final DateTime expiryDate; // e.g. "تنتهي الصلاحية 31 يناير 2024"

  const CouponEntity({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.expiryDate,
  });

  @override
  List<Object?> get props => [code, title, subtitle, expiryDate];
}

class FaqEntity extends Equatable {
  final String question;
  final String answer;

  const FaqEntity({
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [question, answer];
}
