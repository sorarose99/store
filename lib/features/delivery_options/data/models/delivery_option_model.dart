import '../../domain/entities/delivery_option.dart';

class DeliveryOptionModel extends DeliveryOption {
  const DeliveryOptionModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.minDays,
    required super.maxDays,
    required super.price,
  });

  factory DeliveryOptionModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOptionModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      minDays: json['min_days'] ?? 0,
      maxDays: json['max_days'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'min_days': minDays,
      'max_days': maxDays,
      'price': price,
    };
  }
}
