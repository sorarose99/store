import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Result from image analysis — carries both the raw labels and
/// a resolved search query the store API can actually use.
class ImageSearchResult {
  /// The search term(s) to send as `?search=...`
  final String searchQuery;

  /// True when we should use a category slug instead of a text search
  final bool useCategorySlug;

  /// Category slug to use with `?category_name=...` (only when [useCategorySlug])
  final String? categorySlug;

  /// Human-readable description of what was detected (for the UI)
  final String displayLabel;

  const ImageSearchResult({
    required this.searchQuery,
    this.useCategorySlug = false,
    this.categorySlug,
    required this.displayLabel,
  });
}

/// Maps generic English ML-Kit labels to Arabic/store-specific search terms
/// that are more likely to match real product names in the store.
const Map<String, String> _labelToArabicSearch = {
  // Clothing
  'clothing': 'ملابس',
  'dress': 'فستان',
  'gown': 'فستان سهرة',
  't-shirt': 'تيشرت',
  'shirt': 'قميص',
  'blouse': 'بلوزة',
  'top': 'توب',
  'pants': 'بنطال',
  'trousers': 'بنطال',
  'jeans': 'جينز',
  'shorts': 'شورت',
  'skirt': 'تنورة',
  'coat': 'معطف',
  'jacket': 'جاكيت',
  'hoodie': 'هودي',
  'sweater': 'سترة',
  'suit': 'بدلة',
  'abaya': 'عباية',
  'hijab': 'حجاب',
  'underwear': 'ملابس داخلية',
  'swimwear': 'ملابس سباحة',
  'sportswear': 'ملابس رياضية',
  'uniform': 'يونيفورم',
  'outerwear': 'معطف',
  'sleeve': 'ملابس',
  'textile': 'ملابس',
  'fashion': 'موضة',

  // Footwear
  'footwear': 'أحذية',
  'shoe': 'حذاء',
  'shoes': 'أحذية',
  'boot': 'بوت',
  'boots': 'بوت',
  'sneaker': 'حذاء رياضي',
  'sneakers': 'حذاء رياضي',
  'sandal': 'صندل',
  'sandals': 'صندل',
  'heel': 'كعب',
  'heels': 'كعب',
  'slipper': 'شبشب',

  // Bags & accessories
  'bag': 'حقيبة',
  'handbag': 'حقيبة',
  'backpack': 'حقيبة ظهر',
  'wallet': 'محفظة',
  'purse': 'حقيبة',
  'luggage': 'حقيبة سفر',

  // Perfume / beauty
  'perfume': 'عطر',
  'fragrance': 'عطر',
  'cologne': 'عطر',
  'cosmetics': 'مستحضرات تجميل',
  'makeup': 'مكياج',
  'lipstick': 'احمر شفاه',

  // Accessories / jewelry
  'watch': 'ساعة',
  'jewelry': 'مجوهرات',
  'necklace': 'قلادة',
  'bracelet': 'سوار',
  'ring': 'خاتم',
  'earring': 'حلق',
  'glasses': 'نظارة',
  'sunglasses': 'نظارة شمسية',
  'hat': 'قبعة',
  'scarf': 'وشاح',
  'belt': 'حزام',

  // Kids
  'baby': 'أطفال',
  'child': 'أطفال',
  'kids': 'أطفال',
  'toy': 'لعبة',

  // Generic fallbacks
  'product': '',
  'pattern': '',
  'design': '',
  'material': '',
  'fabric': '',
  'person': '',
  'human': '',
  'woman': '',
  'man': '',
  'model': '',
};

/// Category slugs for broad category navigation when text search fails.
const Map<String, String> _labelToCategorySlug = {
  'dress': 'ملابس-نسائية',
  'gown': 'ملابس-نسائية',
  'blouse': 'ملابس-نسائية',
  'skirt': 'ملابس-نسائية',
  'abaya': 'ملابس-نسائية',
  'hijab': 'ملابس-نسائية',
  'shirt': 'ملابس-رجالية',
  'suit': 'ملابس-رجالية',
  't-shirt': 'ملابس-رجالية',
  'hoodie': 'ملابس-رجالية',
  'footwear': 'أحذية-نسائية',
  'shoe': 'أحذية-نسائية',
  'shoes': 'أحذية-نسائية',
  'sneaker': 'أحذية-نسائية',
  'sneakers': 'أحذية-نسائية',
  'sandal': 'أحذية-نسائية',
  'boot': 'أحذية-نسائية',
  'bag': 'حقائب-نسائية',
  'handbag': 'حقائب-نسائية',
  'backpack': 'حقائب-رجالية',
  'perfume': 'مجموعات-مميزة',
  'fragrance': 'مجموعات-مميزة',
  'baby': 'ملابس-أطفال',
  'kids': 'ملابس-أطفال',
};

class DetectedLabel {
  final String label;
  final double confidence;
  const DetectedLabel({required this.label, required this.confidence});
}

class ImageSearchService {
  ImageLabeler? _labeler;

  ImageLabeler _makeLabeler(double threshold) {
    return ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: threshold),
    );
  }

  /// Cloud-based Google Cloud Vision API detection with local fallback.
  Future<List<DetectedLabel>> _detectCloudLabels(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw ImageSearchException('Image file does not exist');
    }
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final payload = {
      'requests': [
        {
          'image': {
            'content': base64Image,
          },
          'features': [
            {'type': 'LABEL_DETECTION', 'maxResults': 15},
            {'type': 'OBJECT_LOCALIZATION', 'maxResults': 15}
          ]
        }
      ]
    };

    String apiKey = 'AIzaSyBkkJ2cTWFSKG26JVeVLJcV8fCntsLTSTA'; // Project's default API key
    try {
      await dotenv.load(fileName: ".env");
      final keyFromEnv = dotenv.env['GOOGLE_CLOUD_VISION_KEY'];
      if (keyFromEnv != null && keyFromEnv.isNotEmpty) {
        apiKey = keyFromEnv;
      }
    } catch (_) {}

    final url = 'https://vision.googleapis.com/v1/images:annotate?key=$apiKey';

    final dio = Dio();
    final response = await dio.post(
      url,
      data: payload,
      options: Options(
        headers: {'Content-Type': 'application/json'},
        sendTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );

    if (response.statusCode != 200) {
      throw ImageSearchException('Cloud Vision status code: ${response.statusCode}');
    }

    final data = response.data;
    final responses = data['responses'] as List?;
    if (responses == null || responses.isEmpty) {
      return [];
    }

    final detected = <DetectedLabel>[];
    final responseItem = responses[0] as Map<String, dynamic>;

    if (responseItem.containsKey('localizedObjectAnnotations')) {
      final objects = responseItem['localizedObjectAnnotations'] as List;
      for (final obj in objects) {
        detected.add(DetectedLabel(
          label: obj['name'] as String,
          confidence: (obj['score'] as num).toDouble(),
        ));
      }
    }

    if (responseItem.containsKey('labelAnnotations')) {
      final labels = responseItem['labelAnnotations'] as List;
      for (final lbl in labels) {
        detected.add(DetectedLabel(
          label: lbl['description'] as String,
          confidence: (lbl['score'] as num).toDouble(),
        ));
      }
    }

    // Sort by confidence descending
    detected.sort((a, b) => b.confidence.compareTo(a.confidence));
    return detected;
  }

  /// Fallback: ML Kit local detection.
  Future<List<DetectedLabel>> _detectLocalLabels(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    // Primary pass: high confidence.
    final primary = _makeLabeler(0.65);
    try {
      final labels = await primary.processImage(inputImage);
      primary.close();
      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      if (labels.length >= 2) {
        return labels.map((l) => DetectedLabel(label: l.label, confidence: l.confidence)).toList();
      }

      // Secondary pass: lower threshold when the primary pass is too sparse.
      final secondary = _makeLabeler(0.45);
      final broader = await secondary.processImage(inputImage);
      secondary.close();
      broader.sort((a, b) => b.confidence.compareTo(a.confidence));
      return broader.map((l) => DetectedLabel(label: l.label, confidence: l.confidence)).toList();
    } catch (_) {
      primary.close();
      rethrow;
    }
  }

  /// Resolves detected labels into the best possible search result.
  ///
  /// Strategy (in order):
  /// 1. Direct Arabic translation of the single best confident label.
  /// 2. Try each of the top-5 labels independently for a translation
  ///    (catches cases where label[0] is a non-clothing generic term).
  /// 3. Try combining 2 translated terms for a broader match.
  /// 4. Fall back to category slug navigation.
  /// 5. Raw English label as last resort.
  Future<ImageSearchResult> resolveSearchResult(String imagePath) async {
    List<DetectedLabel> labels = [];

    // Try Google Cloud Vision API first
    try {
      labels = await _detectCloudLabels(imagePath);
      debugPrint('[ImageSearch] Google Cloud Vision labels: ${labels.map((l) => '${l.label}(${l.confidence.toStringAsFixed(2)})').join(', ')}');
    } catch (e) {
      debugPrint('[ImageSearch] Google Cloud Vision failed or timed out: $e. Falling back to local ML Kit.');
    }

    // Fallback to local ML Kit if cloud vision failed or returned empty
    if (labels.isEmpty) {
      try {
        labels = await _detectLocalLabels(imagePath);
        debugPrint('[ImageSearch] Local ML Kit labels: ${labels.map((l) => '${l.label}(${l.confidence.toStringAsFixed(2)})').join(', ')}');
      } catch (e) {
        debugPrint('[ImageSearch] Local ML Kit fallback failed: $e');
      }
    }

    if (labels.isEmpty) {
      throw ImageSearchException('Could not identify any items in this image');
    }

    // --- Strategy 1: best label direct translation ---
    final bestKey = labels.first.label.toLowerCase().trim();
    final bestArabic = _labelToArabicSearch[bestKey];
    if (bestArabic != null && bestArabic.isNotEmpty) {
      debugPrint('[ImageSearch] Strategy 1: "${labels.first.label}" → "$bestArabic"');
      return ImageSearchResult(searchQuery: bestArabic, displayLabel: bestArabic);
    }

    // --- Strategy 2: scan top-5 labels individually (L9 fix: distinct from S1) ---
    for (final label in labels.skip(1).take(4)) {
      final key = label.label.toLowerCase().trim();
      final arabic = _labelToArabicSearch[key];
      if (arabic != null && arabic.isNotEmpty) {
        debugPrint('[ImageSearch] Strategy 2: "${label.label}" → "$arabic"');
        return ImageSearchResult(searchQuery: arabic, displayLabel: arabic);
      }
    }

    // --- Strategy 3: combine two translated terms for a broader query ---
    final translatedTerms = labels
        .take(8)
        .map((l) => _labelToArabicSearch[l.label.toLowerCase().trim()])
        .where((t) => t != null && t!.isNotEmpty)
        .cast<String>()
        .toList();

    if (translatedTerms.length >= 2) {
      // Two-term combo gives the API more to match against.
      final combined = '${translatedTerms[0]} ${translatedTerms[1]}';
      debugPrint('[ImageSearch] Strategy 3: combined → "$combined"');
      return ImageSearchResult(searchQuery: combined, displayLabel: translatedTerms[0]);
    } else if (translatedTerms.length == 1) {
      debugPrint('[ImageSearch] Strategy 3 (single): "${translatedTerms[0]}"');
      return ImageSearchResult(
          searchQuery: translatedTerms[0], displayLabel: translatedTerms[0]);
    }

    // --- Strategy 4: category slug fallback ---
    for (final label in labels.take(5)) {
      final key = label.label.toLowerCase().trim();
      final slug = _labelToCategorySlug[key];
      if (slug != null) {
        debugPrint('[ImageSearch] Strategy 4: "${label.label}" → category "$slug"');
        return ImageSearchResult(
          searchQuery: slug,
          useCategorySlug: true,
          categorySlug: slug,
          displayLabel: label.label,
        );
      }
    }

    // --- Strategy 5: raw best English label as final fallback ---
    final rawBest = labels.first.label;
    debugPrint('[ImageSearch] Strategy 5: raw fallback "$rawBest"');
    return ImageSearchResult(searchQuery: rawBest, displayLabel: rawBest);
  }

  void dispose() {
    _labeler?.close();
    _labeler = null;
  }
}

class ImageSearchException implements Exception {
  final String message;
  ImageSearchException(this.message);

  @override
  String toString() => message;
}
