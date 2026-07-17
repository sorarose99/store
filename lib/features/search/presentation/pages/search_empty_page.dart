import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import 'search_active_page.dart';
import '../../../camera_search/presentation/pages/camera_search_page.dart';

/// Shown when a search query returns zero results.
/// Accepts the [failedQuery] so it can pre-fill the search bar on retry.
/// When [embedded] is true, renders just the body content (no Scaffold/AppBar)
/// so it can be placed inside a Sliver layout.
class SearchEmptyPage extends StatelessWidget {
  /// The query that produced no results. Used to pre-fill the search bar.
  final String? failedQuery;
  /// When true, skips the Scaffold — renders body content only.
  final bool embedded;

  const SearchEmptyPage({super.key, this.failedQuery, this.embedded = false});

  // L7/U7 fix: both the fake search bar AND the "Try Again" button
  // navigate to SearchActivePage with the failed query pre-filled.
  void _goToSearch(BuildContext context) {
    // Replace this empty-result page with a fresh SearchActivePage so the
    // user can immediately edit their query without seeing a blank back-stack.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SearchActivePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // When embedded inside a Sliver, skip Scaffold/AppBar and render body only
    if (embedded) return _buildBody(context);

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                // ── Illustration ──────────────────────────────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 110,
                      color: context.primaryColor,
                    ),
                    Positioned(
                      bottom: 8.h,
                      left: 10.w,
                      child: Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.textDark.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.radio_button_unchecked_rounded,
                              size: 38,
                              color: context.primaryColor,
                            ),
                            Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: context.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // ── No results message ────────────────────────────────────
                Text(
                  'sorry_no_search_results'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                if (failedQuery != null && failedQuery!.isNotEmpty)
                  Text(
                    '"$failedQuery"',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.textGrey,
                      fontFamily: 'Tajawal',
                    ),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 24.h),

                // ── Try Again button ──────────────────────────────────────
                // U7 fix: pushes SearchActivePage instead of just popping.
                SizedBox(
                  width: 170.w,
                  height: 46.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _goToSearch(context),
                    icon: const Icon(Icons.search, color: Colors.white, size: 18),
                    label: Text(
                      'try_again'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ── Try visual search CTA (U1 enhancement) ───────────────
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CameraSearchPage()),
                    );
                  },
                  icon: Icon(Icons.camera_alt_outlined,
                      color: context.textGrey, size: 18),
                  label: Text(
                    'try_visual_search'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: context.textGrey,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),

                SizedBox(height: 60.h),
              ],
            ),
          ),
        );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.surfaceColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      // L7 fix: the fake search bar is now wrapped in GestureDetector
      // so tapping it navigates back to the live search input.
      title: GestureDetector(
        onTap: () => _goToSearch(context),
        child: Container(
          height: 38.h,
          margin: EdgeInsets.only(left: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.border, width: 0.8),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: context.textGrey, size: 18),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  failedQuery?.isNotEmpty == true
                      ? failedQuery!
                      : 'search_1'.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: failedQuery?.isNotEmpty == true
                        ? context.textDark
                        : context.textGrey,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.close_rounded, color: context.textGrey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
