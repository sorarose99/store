import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';

class NotifySizeBottomSheet extends StatefulWidget {
  const NotifySizeBottomSheet({super.key});

  @override
  State<NotifySizeBottomSheet> createState() => _NotifySizeBottomSheetState();
}

class _NotifySizeBottomSheetState extends State<NotifySizeBottomSheet> {
  String? _selectedSize;

  static const List<String> _exactSizes = [
    '3S, 4S, 5S, 6S, 7S, 8S, S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL, 7XL, 8XL',
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      size: 20, color: context.textDark),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text(
                  'tell_me_your_size'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                  ),
                ),
                SizedBox(width: 20.w), // Balance
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Text(
              'select_size_1'.tr(),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Size Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Directionality(
              textDirection: ui.TextDirection.ltr, // Align chips LTR as in design
              child: Wrap(
                spacing: 8.w,
                runSpacing: 12.w,
                alignment: WrapAlignment.center,
                children: _exactSizes.map((size) {
                  final isSelected = _selectedSize == size;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSize = size;
                      });
                    },
                    child: Container(
                      width: 48.w,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        border: Border.all(
                          color: isSelected
                              ? context.textDark
                              : context.primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        size,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color:
                              isSelected ? context.textDark : context.textGrey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // Send Button
          Padding(
            padding: EdgeInsets.only(
              left: 16.0.w,
              right: 16.0.w,
              bottom: MediaQuery.of(context).padding.bottom + 16.0,
            ),
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed: _selectedSize != null
                    ? () {
                        // Action for Send
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  disabledBackgroundColor: context.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'send'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
