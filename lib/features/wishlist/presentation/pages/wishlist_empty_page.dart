import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

class WishlistEmptyPage extends StatelessWidget {
  const WishlistEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Removed dummy recommendations

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'wishlist'.tr(),
            style: TextStyle(
              color: context.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50.h),

              // Custom Illustration (browser window with X mark and heart icon overlay)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Browser window outline
                    Container(
                      width: 110.w,
                      height: 110.h,
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: context.primaryColor, width: 1.5.w),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Browser header bar
                          Container(
                            height: 18.h,
                            decoration: BoxDecoration(
                              color: context.primaryColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Row(
                              children: [
                                Container(
                                  width: 5.w,
                                  height: 5.h,
                                  decoration: BoxDecoration(
                                    color: context.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Container(
                                  width: 5.w,
                                  height: 5.h,
                                  decoration: BoxDecoration(
                                    color: context.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Container(
                                  width: 5.w,
                                  height: 5.h,
                                  decoration: BoxDecoration(
                                    color: context.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Icon(
                                Icons.favorite_border_rounded,
                                size: 40,
                                color: context.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Heart overlay at top-right
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.textDark.withValues(alpha: 0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: context.primaryColor,
                          size: 16,
                        ),
                      ),
                    ),
                    // X mark overlay at bottom-left
                    Positioned(
                      bottom: -10,
                      left: -10,
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.textDark.withValues(alpha: 0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: context.textGrey,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36.h),

              // Empty State Text
              Text(
                'sorry_no_favorites_were'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 24.h),

              // Go Shopping Button
              SizedBox(
                width: 140.w, // Match mockup button width
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home shell
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'go_shopping'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: context.backgroundColor,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 48.h),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
