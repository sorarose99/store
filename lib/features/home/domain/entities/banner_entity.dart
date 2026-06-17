import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String imageAsset;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String targetCategoryId;

  const BannerEntity({
    required this.id,
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.targetCategoryId,
  });

  @override
  List<Object?> get props =>
      [id, imageAsset, title, subtitle, ctaLabel, targetCategoryId];
}
