import 'dart:developer' as developer;
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

/// A single onboarding slide resolved from either the API or local assets.
class OnboardingSlideData {
  /// Non-null → network image; null → use [assetPath].
  final String? imageUrl;

  /// Non-null → local asset; null → use [imageUrl].
  final String? assetPath;

  final String title;
  final String description;

  const OnboardingSlideData({
    this.imageUrl,
    this.assetPath,
    required this.title,
    required this.description,
  }) : assert(imageUrl != null || assetPath != null,
            'Either imageUrl or assetPath must be provided');

  bool get isNetwork => imageUrl != null && imageUrl!.isNotEmpty;
}

// ── Static fallback slides (used only when the API returns nothing) ──────────
const List<OnboardingSlideData> _staticSlides = [
  OnboardingSlideData(
    assetPath: 'assets/images/onboarding_1.png',
    title: '',
    description: '',
  ),
  OnboardingSlideData(
    assetPath: 'assets/images/onboarding_2.png',
    title: '',
    description: '',
  ),
  OnboardingSlideData(
    assetPath: 'assets/images/onboarding_3.png',
    title: '',
    description: '',
  ),
  OnboardingSlideData(
    assetPath: 'assets/images/onboarding_4.png',
    title: '',
    description: '',
  ),
];


/// Fetches onboarding slides from the API.
///
/// Strategy:
///   1. Call `GET /` (home endpoint) — extracts all banners.
///   2. Call `GET /shop` — extracts shop banner.
///   3. Combine & deduplicate.
///   4. If the API returns nothing → fall back to [_staticSlides].
Future<List<OnboardingSlideData>> fetchOnboardingSlides(
    ApiClient apiClient) async {
  final apiSlides = <OnboardingSlideData>[];

  // ── 1. Home endpoint ──────────────────────────────────────────────────────
  try {
    final homeResp = await apiClient.get(ApiEndpoints.home);
    if (homeResp.data is Map<String, dynamic>) {
      final data = homeResp.data as Map<String, dynamic>;

      // Single banner object
      final bannerObj = data['banner'];
      if (bannerObj is Map<String, dynamic>) {
        final slide = _bannerToSlide(bannerObj);
        if (slide != null) apiSlides.add(slide);
      }

      // Banners list (some APIs return an array)
      final bannersList = data['banners'];
      if (bannersList is List) {
        for (final b in bannersList) {
          if (b is Map<String, dynamic>) {
            final slide = _bannerToSlide(b);
            if (slide != null) apiSlides.add(slide);
          }
        }
      }
    }
  } catch (e) {
    developer.log('Onboarding: home fetch failed: $e',
        name: 'OnboardingDatasource');
  }

  // ── 2. Shop endpoint ──────────────────────────────────────────────────────
  try {
    final shopResp = await apiClient.get(ApiEndpoints.shop);
    if (shopResp.data is Map<String, dynamic>) {
      final shopMap = shopResp.data as Map<String, dynamic>;
      final bannerObj = shopMap['banner'];
      if (bannerObj is Map<String, dynamic>) {
        final slide = _bannerToSlide(bannerObj);
        if (slide != null) apiSlides.add(slide);
      }
    }
  } catch (e) {
    developer.log('Onboarding: shop fetch failed: $e',
        name: 'OnboardingDatasource');
  }

  // ── 3. Deduplicate by image URL ───────────────────────────────────────────
  final seen = <String>{};
  final unique = <OnboardingSlideData>[];
  for (final s in apiSlides) {
    final key = s.imageUrl ?? s.assetPath ?? '';
    if (key.isNotEmpty && seen.add(key)) {
      unique.add(s);
    }
  }

  developer.log(
      'Onboarding: ${unique.length} API slides (from ${apiSlides.length} raw)',
      name: 'OnboardingDatasource');

  // ── 5. Fallback ───────────────────────────────────────────────────────────
  if (unique.isEmpty) {
    developer.log('Onboarding: using static fallback slides',
        name: 'OnboardingDatasource');
    return List.unmodifiable(_staticSlides);
  }

  return List.unmodifiable(unique);
}

/// Converts a banner JSON map into an [OnboardingSlideData], or null if the
/// image URL is empty / missing.
OnboardingSlideData? _bannerToSlide(Map<String, dynamic> json) {
  String img = json['image'] as String? ??
      json['image_path'] as String? ??
      json['image_asset'] as String? ??
      '';

  if (img.isEmpty) return null;

  // Resolve relative paths to full URLs
  if (!img.startsWith('http')) {
    img = img.startsWith('/')
        ? 'https://kdx-sa.com$img'
        : 'https://kdx-sa.com/$img';
  }

  return OnboardingSlideData(
    imageUrl: img,
    title: json['title'] as String? ?? '',
    description: json['subtitle'] as String? ??
        json['description'] as String? ??
        '',
  );
}
