import 'dart:developer' as developer;
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.parentId,
    super.showInHome,
    super.imageAsset,
    super.isSelected,
  });

  /// Safely parse from API JSON, returns null if parsing fails
  static CategoryModel? fromJsonSafe(Map<String, dynamic> json) {
    try {
      return CategoryModel.fromJson(json);
    } catch (e, stackTrace) {
      developer.log('Failed to parse CategoryModel',
          error: e, stackTrace: stackTrace, name: 'CategoryModel');
      return null;
    }
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name_ar'] as String? ??
        json['name_en'] as String? ??
        json['name'] as String? ??
        '';
    final img = json['image'] as String? ??
        json['image_path'] as String? ??
        json['image_asset'] as String? ??
        '';
    String finalImg = '';
    if (img.isNotEmpty) {
      finalImg = ApiEndpoints.mediaUrl(img);
    }

    bool parseBool(dynamic value) {
      return value == 1 || value == true || value == 1 || value == 'true';
    }

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: name,
      slug: json['slug'] as String? ?? json['id']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      showInHome: parseBool(json['show_in_home']),
      imageAsset: finalImg,
      isSelected: json['is_selected'] as bool? ?? false,
    );
  }
}
