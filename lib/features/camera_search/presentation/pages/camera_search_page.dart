import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/colors.dart';
import '../../../search_filter/presentation/pages/product_grid_page.dart';
import '../../data/services/image_search_service.dart';

/// Camera / visual-search screen.
///
/// Lets the user pick an image (camera or gallery), runs it through
/// [ImageSearchService] and navigates to [ProductGridPage] with the
/// resolved search query or category slug.
class CameraSearchPage extends StatefulWidget {
  const CameraSearchPage({super.key});

  @override
  State<CameraSearchPage> createState() => _CameraSearchPageState();
}

class _CameraSearchPageState extends State<CameraSearchPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final ImageSearchService _searchService = ImageSearchService();

  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;
  String? _detectedLabel;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchService.dispose();
    super.dispose();
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return;
      setState(() {
        _selectedImage = File(picked.path);
        _errorMessage = null;
        _detectedLabel = null;
      });
      await _analyzeImage(picked.path);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'camera_permission_error'.tr();
      });
    }
  }

  // ── Image analysis ────────────────────────────────────────────────────────

  Future<void> _analyzeImage(String path) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _searchService.resolveSearchResult(path);

      if (!mounted) return;

      setState(() {
        _detectedLabel = result.displayLabel;
        _isAnalyzing = false;
      });

      // Brief pause so the user can see what was detected.
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProductGridPage(
            title: result.displayLabel,
            filters: {'search': result.searchQuery, 'is_camera': true},
          ),
        ),
      );
    } on ImageSearchException catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'image_analysis_failed'.tr();
      });
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: _selectedImage == null
              ? _buildPickerState(context)
              : _buildAnalyzingState(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'visual_search'.tr(),
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: context.textDark,
          fontFamily: 'Tajawal',
        ),
      ),
      centerTitle: true,
    );
  }

  // ── Initial state: ask user to pick an image ──────────────────────────────
  Widget _buildPickerState(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hero illustration
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    context.primaryColor.withValues(alpha: 0.18),
                    context.primaryColor.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.camera_enhance_rounded,
                size: 60,
                color: context.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // Title
          Text(
            'visual_search_title'.tr(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: context.textDark,
              fontFamily: 'Tajawal',
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          Text(
            'visual_search_subtitle'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              color: context.textGrey,
              fontFamily: 'Tajawal',
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40.h),

          // Camera button
          _ActionButton(
            icon: Icons.camera_alt_rounded,
            label: 'take_photo'.tr(),
            onTap: () => _pickImage(ImageSource.camera),
            primary: true,
            context: context,
          ),
          SizedBox(height: 16.h),

          // Gallery button
          _ActionButton(
            icon: Icons.photo_library_rounded,
            label: 'choose_from_gallery'.tr(),
            onTap: () => _pickImage(ImageSource.gallery),
            primary: false,
            context: context,
          ),

          if (_errorMessage != null) ...[
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: context.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.errorColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: context.errorColor, size: 18),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.errorColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 40.h),

          // Tips
          _buildTipsRow(context),
        ],
      ),
    );
  }

  // ── Analysis state: image preview + spinner ───────────────────────────────
  Widget _buildAnalyzingState(BuildContext context) {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Dark overlay when analyzing
              if (_isAnalyzing)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: context.primaryColor,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'analyzing_image'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Detected label badge
              if (_detectedLabel != null && !_isAnalyzing)
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8.w),
                        Text(
                          _detectedLabel!,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Error state + retry
        if (_errorMessage != null && !_isAnalyzing)
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.errorColor,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _selectedImage = null;
                        _errorMessage = null;
                      }),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        Directionality.of(context) == ui.TextDirection.rtl
                            ? 'رجوع'
                            : 'Back',
                        style: const TextStyle(fontFamily: 'Tajawal'),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _analyzeImage(_selectedImage!.path),
                      icon: const Icon(Icons.refresh),
                      label: Text('retry'.tr(),
                          style: const TextStyle(fontFamily: 'Tajawal')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Bottom: pick new image button
        if (!_isAnalyzing)
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text('take_photo'.tr(),
                        style: const TextStyle(fontFamily: 'Tajawal')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryColor,
                      side: BorderSide(color: context.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text('gallery'.tr(),
                        style: const TextStyle(fontFamily: 'Tajawal')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryColor,
                      side: BorderSide(color: context.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTipsRow(BuildContext context) {
    final tips = [
      (Icons.wb_sunny_rounded, 'tip_good_lighting'.tr()),
      (Icons.center_focus_strong_rounded, 'tip_clear_photo'.tr()),
      (Icons.zoom_in_rounded, 'tip_single_item'.tr()),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tips
          .map((t) => Expanded(
                child: Column(
                  children: [
                    Icon(t.$1, size: 22, color: context.primaryColor),
                    SizedBox(height: 6.h),
                    Text(
                      t.$2,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: context.textGrey,
                        fontFamily: 'Tajawal',
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ── Reusable action button ────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final BuildContext context;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primary,
    required this.context,
  });

  @override
  Widget build(BuildContext outerContext) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: primary
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 20, color: Colors.white),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 20, color: context.primaryColor),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                  color: context.primaryColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }
}
