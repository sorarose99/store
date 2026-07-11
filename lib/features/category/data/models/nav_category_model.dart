import 'dart:developer' as developer;
import '../../domain/entities/nav_category_entity.dart';
import '../../../../core/network/api_endpoints.dart';

class MainCategoryModel extends MainCategoryEntity {
  const MainCategoryModel(
      {required super.id, required super.slug, required super.name});

  static MainCategoryModel? fromJsonSafe(Map<String, dynamic> json) {
    try {
      return MainCategoryModel.fromJson(json);
    } catch (e, stackTrace) {
      developer.log('Failed to parse MainCategoryModel',
          error: e, stackTrace: stackTrace, name: 'MainCategoryModel');
      return null;
    }
  }

  factory MainCategoryModel.fromJson(Map<String, dynamic> json) {
    return MainCategoryModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug'] as String? ?? json['id']?.toString() ?? '',
      name: json['name_ar'] as String? ??
          json['name_en'] as String? ??
          json['name'] as String? ??
          '',
    );
  }
}

class SubCategoryModel extends SubCategoryEntity {
  const SubCategoryModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.imageAsset,
  });

  static SubCategoryModel? fromJsonSafe(Map<String, dynamic> json) {
    try {
      return SubCategoryModel.fromJson(json);
    } catch (e, stackTrace) {
      developer.log('Failed to parse SubCategoryModel',
          error: e, stackTrace: stackTrace, name: 'SubCategoryModel');
      return null;
    }
  }

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    final img = json['image_url'] as String? ??
        json['image'] as String? ??
        json['image_path'] as String? ??
        json['image_asset'] as String? ??
        '';
    String finalImg = img;
    if (img.isNotEmpty && !img.startsWith('http')) {
      finalImg = ApiEndpoints.mediaUrl(img);
    }
    return SubCategoryModel(
      id: json['id']?.toString() ?? '',
      slug: json['slug'] as String? ?? json['id']?.toString() ?? '',
      name: json['name_ar'] as String? ??
          json['name_en'] as String? ??
          json['name'] as String? ??
          '',
      imageAsset: finalImg,
    );
  }
}
