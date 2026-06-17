import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String imageAsset;
  final bool isSelected;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.imageAsset,
    this.isSelected = false,
  });

  @override
  List<Object?> get props => [id, name, imageAsset, isSelected];
}
