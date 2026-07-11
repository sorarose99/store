import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/product_details_entity.dart';

class ProductSpecsPage extends StatelessWidget {
  final ProductDetailsEntity productDetails;

  const ProductSpecsPage({super.key, required this.productDetails});

  @override
  Widget build(BuildContext context) {
    final base = productDetails.baseProduct;
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor.withValues(alpha: 0.8),
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'product_details_and_specifications'.tr(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
              color: context.textDark,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Title & Brand
              Text(
                base.brand,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                  letterSpacing: 0.5,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                base.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 16.h),

              // SKU Section
              if (productDetails.sku != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: context.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.border, width: 0.8.w),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SKU / رقم الصنف',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: context.textGrey,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            productDetails.sku!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: context.textDark,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: productDetails.sku!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم نسخ رقم الصنف: ${productDetails.sku!}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 14.sp, color: context.primaryColor),
                              SizedBox(width: 4.w),
                              Text(
                                'copy'.tr(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryColor,
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
                SizedBox(height: 20.h),
              ],

              // Full Description
              Text(
                'about_product'.tr(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                productDetails.description,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.textMid,
                  height: 1.8.h,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 24.h),

              // Specifications list (sizes, colors, tags)
              if (productDetails.availableSizes.isNotEmpty) ...[
                Text(
                  'available_sizes'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: productDetails.availableSizes.map((size) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.border, width: 0.8.w),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
              ],

              if (productDetails.availableColors.isNotEmpty) ...[
                Text(
                  'available_colors'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: productDetails.availableColors.map((colorName) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: context.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.border, width: 0.8.w),
                      ),
                      child: Text(
                        colorName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
              ],

              if (productDetails.tags.isNotEmpty) ...[
                Text(
                  'tags'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                    fontFamily: 'Tajawal',
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: productDetails.tags.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
