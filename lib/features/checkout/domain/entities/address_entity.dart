class AddressEntity {
  final String id;
  final String fullName;
  final String phone;
  final String country;
  final String city;
  final String state;
  final String zipCode;
  final String addressLine1;
  final String addressLine2;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.addressLine1,
    this.addressLine2 = '',
    this.isDefault = false,
  });
}
