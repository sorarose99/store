import 'package:equatable/equatable.dart';

class DeliveryOption extends Equatable {
  final String id;
  final String type; // e.g., 'free', 'fast'
  final String title;
  final String description;
  final int minDays;
  final int maxDays;
  final double price;

  const DeliveryOption({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.minDays,
    required this.maxDays,
    required this.price,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        minDays,
        maxDays,
        price,
      ];
}
