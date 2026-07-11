import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.image,
    required super.title,
    required super.subtitle,
    super.link,
    super.position,
    super.endDate,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    String img = json['image'] as String? ??
        json['image_path'] as String? ??
        json['image_asset'] as String? ??
        '';

    if (img.isNotEmpty) {
      img = ApiEndpoints.mediaUrl(img);
    }

    return BannerModel(
      id: json['id']?.toString() ?? '',
      image: img,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      link: json['link'] as String?,
      position: json['position'] as String?,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
    );
  }
}
