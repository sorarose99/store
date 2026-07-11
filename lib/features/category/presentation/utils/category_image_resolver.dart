import 'package:easy_localization/easy_localization.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio_pkg;
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_endpoints.dart';

class CategoryImageResolver {
  // Singleton instance
  static final CategoryImageResolver _instance =
      CategoryImageResolver._internal();
  factory CategoryImageResolver() => _instance;
  CategoryImageResolver._internal();

  // Cache: slug -> resolved image URL or Asset Path
  final Map<String, String> _cache = {};

  // Track fallbacks to ensure uniqueness
  final List<String> _allFallbacks = [
    'assets/images/fallback_cat_0.png',
    'assets/images/fallback_cat_3.png',
    'assets/images/fallback_cat_9.png',
  ];
  final Set<String> _usedFallbacks = {};
  final Random _random = Random();

  final Map<String, String> _assignedHomeImages = {};
  final List<String> _allCategoryImages = [
    'assets/images/cat_fashion.png',
    'assets/images/cat_dresses.png',
    'assets/images/cat_shoes.png',
    'assets/images/cat_bags.png',
    'assets/images/cat_beauty.png',
    'assets/images/cat_coat.png',
    'assets/images/cat_boot.png',
    'assets/images/cat_excessories.png',
    'assets/images/cat_plazer.png',
    'assets/images/cat_scarf.png',
    'assets/images/cat_shirt.png',
    'assets/images/cat_modest.png',
  ];

  String getUniqueHardcodedImage(String id, String name, String slug) {
    if (_assignedHomeImages.containsKey(id)) {
      return _assignedHomeImages[id]!;
    }

    // Try to find a matching one first
    String? matched = _getHardcodedAsset(name, slug);
    if (matched != null && !_assignedHomeImages.values.contains(matched)) {
      _assignedHomeImages[id] = matched;
      return matched;
    }

    // Otherwise, pick the first available one
    for (final img in _allCategoryImages) {
      if (!_assignedHomeImages.values.contains(img)) {
        _assignedHomeImages[id] = img;
        return img;
      }
    }

    // If we run out, return a fallback that isn't used
    return _getUniqueFallback();
  }

  /// Resolves the image for a category.
  /// Returns a ValueNotifier that emits the image path/url.
  ///
  /// Priority:
  /// 1. Hardcoded Asset mapping (based on name or slug)
  /// 2. Cached URL
  /// 3. Random UNIQUE fallback asset
  ValueNotifier<String> resolveImage({
    required String slug,
    required String name,
    String? mainSlug,
  }) {
    // Check Cache first for all
    if (_cache.containsKey(slug)) {
      return ValueNotifier(_cache[slug]!);
    }

    // 1. Determine the initial placeholder/static asset image (instant load)
    final initialImage = getUniqueHardcodedImage(slug, name, slug);

    final notifier = ValueNotifier(initialImage);

    // 2. Kick off lazy dynamic background fetch for the first product's image!
    // If it succeeds, it will replace the initial static asset/placeholder.
    _fetchDynamicImage(slug, mainSlug, notifier, initialImage);

    return notifier;
  }

  Future<void> _fetchDynamicImage(String slug, String? mainSlug,
      ValueNotifier<String> notifier, String initialImage) async {
    try {
      final dio = sl.get<dio_pkg.Dio>();
      dio_pkg.Response response;

      if (mainSlug != null && mainSlug.isNotEmpty) {
        // It's a subcategory, we can fetch products directly
        response = await dio.get(ApiEndpoints.categoryProducts(mainSlug, slug));
      } else {
        // It's a main category (like on the home page). The API doesn't return products directly.
        // 1. Fetch category details to get its subcategories
        final detailResponse = await dio.get(ApiEndpoints.categoryDetails(slug));
        
        String? firstSubSlug;
        if (detailResponse.data is Map && detailResponse.data['sub_categories'] is List) {
          final subCats = detailResponse.data['sub_categories'] as List;
          if (subCats.isNotEmpty && subCats.first is Map) {
            firstSubSlug = subCats.first['slug']?.toString();
          }
        }

        // 2. Fetch products for the first subcategory to extract the image
        if (firstSubSlug != null && firstSubSlug.isNotEmpty) {
          response = await dio.get(ApiEndpoints.categoryProducts(slug, firstSubSlug));
        } else {
          // Fallback if it has no subcategories
          response = await dio.get(ApiEndpoints.category(slug));
        }
      }

      if (response.data is Map && response.data['products'] != null) {
        final productsData = response.data['products'];
        List<dynamic> productsList = [];
        if (productsData is Map && productsData['data'] is List) {
          productsList = productsData['data'] as List<dynamic>;
        } else if (productsData is List) {
          productsList = productsData;
        }

        if (productsList.isNotEmpty) {
          String? imgPath;
          for (final product in productsList) {
            if (product is Map) {
              final primaryImg = product['primary_image'];
              if (primaryImg is Map) {
                imgPath = primaryImg['path']?.toString() ??
                    primaryImg['image_path']?.toString();
              }
              imgPath ??= product['image']?.toString() ??
                  product['image_path']?.toString() ??
                  product['image_asset']?.toString();
                  
              if (imgPath != null && imgPath.isNotEmpty) {
                break; // Found a valid image!
              }
            }
          }

          if (imgPath != null && imgPath.isNotEmpty) {
            final url = ApiEndpoints.mediaUrl(imgPath);
            _cache[slug] = url;
            // Stagger UI updates to completely prevent main thread lag / frame drops
            await Future.delayed(
                Duration(milliseconds: 100 + _random.nextInt(400)));
            if (notifier.value == initialImage) {
              // Ensure it wasn't replaced
              notifier.value = url;
            }
          }
        }
      }
    } catch (e) {
      // Ignore errors, it gracefully leaves the placeholder active.
    }
  }

  String? _getHardcodedAsset(String name, String slug) {
    final search = '$name $slug'.toLowerCase();

    // Massive Deep-Scan Map
    if (search.contains('dress'.tr()) ||
        search.contains('dresses'.tr()) ||
        search.contains('dress')) {
      return 'assets/images/cat_dresses.png';
    }
    if (search.contains('shoes_1'.tr()) ||
        search.contains('shoes'.tr()) ||
        search.contains('shoes') ||
        search.contains('sandal'.tr()) ||
        search.contains('snicker'.tr())) {
      return 'assets/images/cat_shoes.png';
    }
    if (search.contains('bag'.tr()) ||
        search.contains('bags_1'.tr()) ||
        search.contains('bag')) {
      return 'assets/images/cat_bags.png';
    }
    if (search.contains('beautification'.tr()) ||
        search.contains('makeup'.tr()) ||
        search.contains('perfume'.tr()) ||
        search.contains('beauty') ||
        search.contains('perfume') ||
        search.contains('makeup')) {
      return 'assets/images/cat_beauty.png';
    }
    if (search.contains('coat'.tr()) ||
        search.contains('jacket'.tr()) ||
        search.contains('coat') ||
        search.contains('jacket')) {
      return 'assets/images/cat_coat.png';
    }
    if (search.contains('bot'.tr()) || search.contains('boot')) {
      return 'assets/images/cat_boot.png';
    }
    if (search.contains('accessory'.tr()) ||
        search.contains('headmasters'.tr()) ||
        search.contains('messenger'.tr()) ||
        search.contains('quintessential'.tr()) ||
        search.contains('accessories') ||
        search.contains('watch') ||
        search.contains('jewelry') ||
        search.contains('ring')) {
      return 'assets/images/cat_excessories.png';
    }
    if (search.contains('blazer'.tr()) || search.contains('blazer')) {
      return 'assets/images/cat_plazer.png';
    }
    if (search.contains('shawl'.tr()) ||
        search.contains('scarf'.tr()) ||
        search.contains('scarf')) {
      return 'assets/images/cat_scarf.png';
    }
    if (search.contains('shirt'.tr()) ||
        search.contains('tshirt'.tr()) ||
        search.contains('tops'.tr()) ||
        search.contains('blues'.tr()) ||
        search.contains('shirt') ||
        search.contains('top')) {
      return 'assets/images/cat_shirt.png';
    }
    if (search.contains('decent'.tr()) ||
        search.contains('veil'.tr()) ||
        search.contains('abay'.tr()) ||
        search.contains('modest') ||
        search.contains('abaya')) {
      return 'assets/images/cat_modest.png';
    }
    if (search.contains('kits'.tr()) ||
        search.contains('instead'.tr()) ||
        search.contains('suit') ||
        search.contains('set')) {
      return 'assets/images/categories/fashion_hero.png';
    }
    if (search.contains('oven'.tr()) ||
        search.contains('skirts'.tr()) ||
        search.contains('skirt')) {
      return 'assets/images/cat_dresses.png'; // closest match
    }
    if (search.contains('shorts'.tr()) || search.contains('short')) {
      return 'assets/images/categories/sports_hero.png';
    }
    if (search.contains('underwear'.tr()) ||
        search.contains('nightwear'.tr()) ||
        search.contains('lingerie') ||
        search.contains('sleep')) {
      return 'assets/images/cat_modest.png'; // fallback context
    }
    if (search.contains('fashion_1'.tr()) ||
        search.contains('fashion'.tr()) ||
        search.contains('fashion')) {
      return 'assets/images/cat_fashion.png';
    }
    if (search.contains('riyadh'.tr()) || search.contains('sport')) {
      return 'assets/images/categories/sports_hero.png';
    }

    return null;
  }

  String _getUniqueFallback() {
    if (_usedFallbacks.length >= _allFallbacks.length) {
      _usedFallbacks.clear();
    }
    final available =
        _allFallbacks.where((f) => !_usedFallbacks.contains(f)).toList();
    if (available.isEmpty) return _allFallbacks.first;
    final chosen = available[_random.nextInt(available.length)];
    _usedFallbacks.add(chosen);
    return chosen;
  }
}
