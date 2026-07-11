import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final bool showInHome;
  final String imageAsset;
  final bool isSelected;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.showInHome = false,
    this.imageAsset = '',
    this.isSelected = false,
  });

  @override
  List<Object?> get props =>
      [id, name, slug, parentId, showInHome, imageAsset, isSelected];
}
