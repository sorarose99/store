import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  final String id;
  final String name;
  final String imageAsset;
  final String discountLabel; // e.g. '40'.tr()

  const BrandEntity({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.discountLabel,
  });

  @override
  List<Object?> get props => [id, name, imageAsset, discountLabel];
}
