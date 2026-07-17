import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// ─────────────────────────────────────────────────────────────────
///  Image Search Service  (Free, On-Device Only)
///
///  Uses Google ML Kit Image Labeling (100% free, no API key needed).
///
///  Three-pass confidence scanning ensures maximum label extraction:
///    Pass 1 – 0.75  (high confidence, precise labels)
///    Pass 2 – 0.55  (medium, if pass 1 gives < 2 labels)
///    Pass 3 – 0.40  (low,    if pass 2 still sparse)
///
///  Query building strategy:
///    • ALWAYS put item type first  (e.g. فستان)
///    • Then ONE color              (e.g. احمر)
///    • Then ONE pattern/material   (e.g. مورد)
///    • MAX 3 Arabic words → backend gets a clean, matchable query
///
///  The ShopBloc handles "no results" by retrying with just the item
///  word (first keyword), so the experience degrades gracefully.
/// ─────────────────────────────────────────────────────────────────

class ImageSearchResult {
  final String searchQuery;
  final String displayLabel;

  const ImageSearchResult({
    required this.searchQuery,
    required this.displayLabel,
  });
}

class ImageSearchException implements Exception {
  final String message;
  ImageSearchException(this.message);
  @override
  String toString() => message;
}

class DetectedLabel {
  final String label;
  final double confidence;
  const DetectedLabel({required this.label, required this.confidence});
}

// ── Arabic vocabulary maps ─────────────────────────────────────────────────
// Keys are lowercase English labels as returned by ML Kit.

const Map<String, String> _enToAr = {
  // Dresses & one-pieces
  'dress': 'فستان', 'gown': 'فستان سهرة', 'evening gown': 'فستان سهرة',
  'maxi dress': 'فستان ماكسي', 'mini dress': 'فستان قصير',
  'midi dress': 'فستان ميدي', 'day dress': 'فستان يومي',
  'sundress': 'فستان صيفي', 'wrap dress': 'فستان ملفوف',
  'romper': 'رومبير', 'jumpsuit': 'جمبسوت', 'bodysuit': 'بودي سوت',
  'overalls': 'أوفرول',

  // Tops
  't-shirt': 'تيشرت', 'tshirt': 'تيشرت', 'shirt': 'قميص',
  'blouse': 'بلوزة', 'top': 'توب', 'tank top': 'توب',
  'crop top': 'كروب توب', 'tube top': 'توب',
  'sweater': 'سترة', 'sweatshirt': 'سويت شيرت',
  'hoodie': 'هودي', 'polo': 'بولو', 'polo shirt': 'قميص بولو',
  'vest': 'فيست', 'cardigan': 'كارديجان',

  // Outerwear
  'jacket': 'جاكيت', 'blazer': 'بليزر', 'coat': 'معطف',
  'trench coat': 'تشمبر', 'puffer jacket': 'جاكيت منفوخ',
  'leather jacket': 'جاكيت جلد', 'denim jacket': 'جاكيت جينز',
  'outerwear': 'ملابس خارجية',

  // Modest fashion
  'abaya': 'عباية', 'hijab': 'حجاب', 'kaftan': 'قفطان',
  'kimono': 'كيمونو', 'bisht': 'بشت',

  // Bottoms
  'pants': 'بنطال', 'trousers': 'بنطال', 'jeans': 'جينز',
  'denim': 'جينز', 'shorts': 'شورت', 'skirt': 'تنورة',
  'mini skirt': 'تنورة قصيرة', 'leggings': 'ليغنز',
  'joggers': 'جوجر', 'sweatpants': 'بنطال رياضي',
  'chinos': 'شينو', 'culottes': 'كولوت',

  // Footwear
  'shoe': 'حذاء', 'shoes': 'أحذية', 'boot': 'بوت', 'boots': 'بوت',
  'footwear': 'أحذية', 'ankle boot': 'أنكل بوت',
  'sneaker': 'سنيكرز', 'sneakers': 'سنيكرز',
  'running shoe': 'حذاء رياضي', 'athletic shoe': 'حذاء رياضي',
  'sandal': 'صندل', 'sandals': 'صندل',
  'heel': 'كعب عالي', 'heels': 'كعب عالي', 'high heel': 'كعب عالي',
  'stiletto': 'ستيليتو', 'slipper': 'شبشب', 'slippers': 'شبشب',
  'loafer': 'لوفر', 'mule': 'ميول', 'flat shoe': 'حذاء مسطح',
  'oxford': 'أوكسفورد', 'pump': 'بامب', 'flip flops': 'شبشب',
  'platform shoe': 'حذاء بلاتفورم',

  // Bags & wallets
  'bag': 'حقيبة', 'handbag': 'حقيبة يد',
  'shoulder bag': 'حقيبة كتف', 'crossbody bag': 'حقيبة كروس',
  'backpack': 'حقيبة ظهر', 'tote bag': 'توت باج', 'clutch': 'كلتش',
  'wallet': 'محفظة', 'purse': 'حقيبة', 'satchel': 'ساتشيل',
  'belt bag': 'حقيبة حزام', 'mini bag': 'ميني باج',
  'fanny pack': 'حقيبة حزام', 'messenger bag': 'حقيبة كروس',

  // Accessories
  'watch': 'ساعة', 'jewelry': 'مجوهرات', 'necklace': 'قلادة',
  'bracelet': 'سوار', 'ring': 'خاتم', 'earring': 'حلق',
  'earrings': 'حلق', 'sunglasses': 'نظارة شمس', 'glasses': 'نظارة',
  'hat': 'قبعة', 'cap': 'كاب', 'scarf': 'وشاح', 'belt': 'حزام',
  'tie': 'كرافت', 'bow tie': 'بابيون',

  // Formalwear
  'suit': 'بدلة', 'tuxedo': 'سموكن', 'formal': 'رسمي',

  // Beauty
  'perfume': 'عطر', 'fragrance': 'عطر', 'cologne': 'كولونيا',
  'makeup': 'مكياج', 'lipstick': 'أحمر شفاه',

  // Sportswear
  'sportswear': 'ملابس رياضية', 'activewear': 'ملابس رياضية',
  'swimwear': 'ملابس سباحة', 'bikini': 'بيكيني',

  // Kids
  'baby': 'ملابس أطفال', 'kids': 'ملابس أطفال',
  'children': 'أطفال', "children's clothing": 'ملابس أطفال',

  // Loungewear & intimates
  'loungewear': 'ملابس منزل', 'sleepwear': 'ملابس نوم',
  'pajamas': 'بيجامة', 'lingerie': 'لانجري',
  'underwear': 'ملابس داخلية', 'socks': 'جوارب', 'tights': 'كولون',
};

const Map<String, String> _colorToAr = {
  'red': 'احمر', 'blue': 'ازرق', 'navy blue': 'كحلي', 'green': 'اخضر',
  'black': 'اسود', 'white': 'ابيض', 'yellow': 'اصفر', 'pink': 'وردي',
  'hot pink': 'وردي فاقع', 'purple': 'بنفسجي', 'brown': 'بني',
  'orange': 'برتقالي', 'grey': 'رمادي', 'gray': 'رمادي', 'beige': 'بيج',
  'maroon': 'عنابي', 'navy': 'كحلي', 'teal': 'تيل', 'gold': 'ذهبي',
  'silver': 'فضي', 'cream': 'كريمي', 'khaki': 'خاكي', 'mint': 'نعناعي',
  'coral': 'مرجاني', 'lavender': 'بنفسجي فاتح', 'nude': 'نود',
  'burgundy': 'عنابي', 'olive': 'زيتي', 'mustard': 'خردلي',
  'peach': 'خوخي', 'cyan': 'سماوي', 'magenta': 'ماجنتا',
  'turquoise': 'تركواز', 'rose': 'وردي', 'ivory': 'عاجي',
  'charcoal': 'رمادي داكن', 'tan': 'بيج', 'lilac': 'ليلكي',
  'emerald': 'زمردي', 'cobalt': 'كوبالت',
};

const Map<String, String> _patternToAr = {
  // Patterns
  'floral': 'مورد', 'striped': 'مخطط', 'plaid': 'كاروهات',
  'checked': 'مربعات', 'checkered': 'مربعات', 'polka dot': 'بقع',
  'animal print': 'طباعة حيوانات', 'leopard': 'ليوبارد',
  'zebra': 'زيبرا', 'camouflage': 'كامو', 'paisley': 'بيزلي',
  'geometric': 'هندسي', 'abstract': 'مجرد',

  // Textures & materials
  'embroidered': 'مطرز', 'lace': 'دانتيل', 'sequin': 'ترتر',
  'velvet': 'مخمل', 'leather': 'جلد', 'silk': 'حرير', 'satin': 'ساتان',
  'knit': 'تريكو', 'crochet': 'كروشيه', 'cotton': 'قطن',
  'linen': 'كتان', 'wool': 'صوف', 'cashmere': 'كشمير',
  'polyester': 'بوليستر', 'chiffon': 'شيفون', 'mesh': 'شبك',
  'denim': 'دنيم', 'suede': 'سويدي', 'faux fur': 'فرو صناعي',
  'tweed': 'تويد', 'jersey': 'جيرسي',

  // Style descriptors
  'casual': 'كاجوال', 'vintage': 'فينتاج', 'retro': 'ريترو',
  'summer': 'صيفي', 'winter': 'شتوي', 'spring': 'ربيعي',
  'long sleeve': 'كم طويل', 'short sleeve': 'كم قصير',
  'sleeveless': 'بدون أكمام', 'v-neck': 'ياقة V',
  'crew neck': 'ياقة دائرية', 'turtleneck': 'ياقة عالية',
  'off shoulder': 'اوف شولدر', 'backless': 'ظهر مكشوف',
  'ruffle': 'كشكش', 'pleated': 'مكرمش', 'wrap': 'ملفوف',
};

// ── Service ────────────────────────────────────────────────────────────────

class ImageSearchService {
  // No Dio, no API keys — purely on-device.

  // ══════════════════════════════════════════════════════════════════
  // Core: ML Kit three-pass confidence scanning
  // ══════════════════════════════════════════════════════════════════

  Future<List<DetectedLabel>> _runMlKit(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    List<ImageLabel> results = [];

    // Pass 1: High confidence (0.75)
    final labeler1 = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.75),
    );
    try {
      results = await labeler1.processImage(input);
      await labeler1.close();
    } catch (e) {
      await labeler1.close();
      debugPrint('[CameraSearch] ML Kit pass 1 error: $e');
    }

    // Pass 2: Medium confidence (0.55) if we have fewer than 2 good labels
    if (results.length < 2) {
      final labeler2 = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.55),
      );
      try {
        results = await labeler2.processImage(input);
        await labeler2.close();
      } catch (e) {
        await labeler2.close();
        debugPrint('[CameraSearch] ML Kit pass 2 error: $e');
      }
    }

    // Pass 3: Low confidence (0.40) as last resort for sparse results
    if (results.length < 2) {
      final labeler3 = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.40),
      );
      try {
        results = await labeler3.processImage(input);
        await labeler3.close();
      } catch (e) {
        await labeler3.close();
        debugPrint('[CameraSearch] ML Kit pass 3 error: $e');
      }
    }

    // Sort highest confidence first
    results.sort((a, b) => b.confidence.compareTo(a.confidence));

    final labels = results
        .map((r) => DetectedLabel(label: r.label, confidence: r.confidence))
        .toList();

    debugPrint(
      '[CameraSearch] ML Kit labels: '
      '${labels.take(6).map((l) => "${l.label}(${l.confidence.toStringAsFixed(2)})").join(", ")}',
    );

    return labels;
  }

  // ══════════════════════════════════════════════════════════════════
  // Query builder: item first, then one color, then one pattern
  // MAX 3 Arabic words for backend compatibility
  // ══════════════════════════════════════════════════════════════════

  ImageSearchResult _buildQuery(List<DetectedLabel> labels) {
    String? itemAr;
    String? colorAr;
    String? patternAr;

    for (final label in labels) {
      final k = label.label.toLowerCase().trim();
      if (_isGenericWord(k)) continue;

      // Try multi-word phrase match first (longer keys take priority)
      final phraseResult = _matchPhrase(k);
      if (phraseResult != null) {
        if (phraseResult.type == _MatchType.item && itemAr == null) {
          itemAr = phraseResult.arabic;
        } else if (phraseResult.type == _MatchType.color && colorAr == null) {
          colorAr = phraseResult.arabic;
        } else if (phraseResult.type == _MatchType.pattern && patternAr == null) {
          patternAr = phraseResult.arabic;
        }
        continue;
      }

      // Single-word exact match
      if (itemAr == null && _enToAr.containsKey(k)) {
        itemAr = _enToAr[k];
      } else if (colorAr == null && _colorToAr.containsKey(k)) {
        colorAr = _colorToAr[k];
      } else if (patternAr == null && _patternToAr.containsKey(k)) {
        patternAr = _patternToAr[k];
      }
    }

    if (itemAr == null) {
      throw ImageSearchException(
        'لم يتم التعرف على المنتج. يرجى التقاط صورة أوضح للقطعة.',
      );
    }

    // Build query: item [color] [pattern] — max 3 words
    final parts = <String>[itemAr];
    if (colorAr != null) parts.add(colorAr);
    if (patternAr != null) parts.add(patternAr);

    final query = parts.join(' ');
    debugPrint('[CameraSearch] Final query: "$query"');

    return ImageSearchResult(
      searchQuery: query,
      displayLabel: itemAr,
    );
  }

  /// Scans the label string for any known phrase (longest match wins).
  _PhraseMatch? _matchPhrase(String text) {
    // Sort keys by length descending to prefer longer phrases
    final allItems = _enToAr.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    final allColors = _colorToAr.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    final allPatterns = _patternToAr.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    for (final e in allItems) {
      if (text.contains(e.key)) {
        return _PhraseMatch(_MatchType.item, e.value);
      }
    }
    for (final e in allColors) {
      if (text.contains(e.key)) {
        return _PhraseMatch(_MatchType.color, e.value);
      }
    }
    for (final e in allPatterns) {
      if (text.contains(e.key)) {
        return _PhraseMatch(_MatchType.pattern, e.value);
      }
    }
    return null;
  }

  /// Labels that ML Kit commonly returns but are useless for product search.
  bool _isGenericWord(String w) => const {
    'fashion', 'clothing', 'apparel', 'wear', 'outfit', 'style',
    'textile', 'fabric', 'product', 'item', 'object', 'brand',
    'model', 'person', 'woman', 'man', 'people', 'human', 'body',
    'hand', 'leg', 'arm', 'face', 'head', 'hair', 'skin', 'neck',
    'finger', 'pattern', 'design', 'color', 'colour', 'material',
    'collection', 'set', 'photo', 'image', 'background', 'surface',
    'room', 'indoor', 'outdoor', 'daylight', 'snapshot', 'portrait',
    'stock photography', 'photography', 'art', 'illustration',
    'visual arts', 'performing arts', 'muscle', 'shoulder', 'waist',
    'sitting', 'standing', 'posing', 'gesture', 'stock',
  }.contains(w);

  // ══════════════════════════════════════════════════════════════════
  // Public entry point
  // ══════════════════════════════════════════════════════════════════

  Future<ImageSearchResult> resolveSearchResult(String imagePath) async {
    final labels = await _runMlKit(imagePath);

    if (labels.isEmpty) {
      throw ImageSearchException(
        'لم يتم التعرف على المنتج. يرجى التقاط صورة أوضح.',
      );
    }

    return _buildQuery(labels);
  }

  void dispose() {
    // Nothing to dispose — no persistent resources.
  }
}

// ── Internal helpers ───────────────────────────────────────────────────────

enum _MatchType { item, color, pattern }

class _PhraseMatch {
  final _MatchType type;
  final String arabic;
  const _PhraseMatch(this.type, this.arabic);
}
