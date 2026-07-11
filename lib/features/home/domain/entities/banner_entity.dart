import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final String? link;
  final String? position;
  final DateTime? endDate;

  const BannerEntity({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    this.link,
    this.position,
    this.endDate,
  });

  @override
  List<Object?> get props =>
      [id, image, title, subtitle, link, position, endDate];
}
