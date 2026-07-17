import '../../domain/entities/checkout_entities.dart';

class SavedAddressModel extends SavedAddressEntity {
  SavedAddressModel({
    required super.id,
    required super.title,
    required super.fullName,
    required super.phone,
    required super.email,
    required super.country,
    required super.city,
    required super.zipCode,
    required super.detailedAddress,
    super.isDefault,
  });

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      zipCode: json['postal_code']?.toString() ?? '',
      detailedAddress: json['address']?.toString() ?? '',
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'country': country,
      'city': city,
      'postal_code': zipCode,
      'address': detailedAddress,
    };
    if (isDefault) {
      data['is_default'] = true;
    }
    return data;
  }
}
