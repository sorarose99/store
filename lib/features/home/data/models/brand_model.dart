import '../../domain/entities/brand_entity.dart';

class BrandModel extends BrandEntity {
  const BrandModel({
    required super.id,
    required super.name,
    required super.imageAsset,
    required super.discountLabel,
  });

  static BrandModel? fromJsonSafe(Map<String, dynamic> json) {
    try {
      return BrandModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      imageAsset:
          json['logo'] as String? ?? json['image_asset'] as String? ?? '',
      discountLabel: (json['discount_label'] as String?) ??
          (json['products_count'] != null
              ? '${json['products_count']} منتجات'
              : ''),
    );
  }
}
