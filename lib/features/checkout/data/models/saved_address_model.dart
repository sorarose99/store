import '../../domain/entities/checkout_entities.dart';

class SavedAddressModel extends SavedAddressEntity {
  SavedAddressModel({
    required super.id,
    required super.recipientName,
    required super.phone,
    required super.city,
    required super.district,
    required super.street,
    required super.buildingNo,
    required super.floor,
    required super.zipCode,
    super.isDefault,
  });

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    final fullAddr = json['address'] as String? ?? '';
    final parts = fullAddr.split(RegExp(r'[،,]'));
    final street = parts.isNotEmpty ? parts[0].trim() : '';
    final district = parts.length > 1 ? parts[1].trim() : '';
    final buildingNo = parts.length > 2 ? parts[2].trim() : '';
    return SavedAddressModel(
      id: json['id']?.toString() ?? '',
      recipientName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: district,
      street: street.isNotEmpty ? street : fullAddr,
      buildingNo: buildingNo,
      floor: '',
      zipCode: json['postal_code'] as String? ?? '',
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': 'Home',
      'full_name': recipientName,
      'phone': phone,
      'country': 'SA',
      'city': city,
      'postal_code': zipCode,
      'address':
          [street, district, buildingNo].where((s) => s.isNotEmpty).join(', '),
    };
    if (isDefault) {
      data['is_default'] = true;
    }
    return data;
  }
}
