import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/review_entity.dart';

class ReviewDistributionWidget extends StatelessWidget {
  final Map<int, double> distribution;
  final double averageRating;
  final int totalReviews;

  const ReviewDistributionWidget({
    super.key,
    required this.distribution,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'reviews'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.textDark,
              ),
            ),
            Text(
              '(أكثر من $totalReviews)',
              style: TextStyle(
                fontSize: 12.sp,
                color: context.textGrey,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Side: Average Rating Number
            Column(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textDark,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < averageRating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: context.primaryColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 24.w),
            // Right Side: Distribution Bars
            Expanded(
              child: Column(
                children: [
                  _buildBarRow(
                      context, 'excellent'.tr(), distribution[5] ?? 0.0),
                  SizedBox(height: 4.h),
                  _buildBarRow(
                      context, 'very_good'.tr(), distribution[4] ?? 0.0),
                  SizedBox(height: 4.h),
                  _buildBarRow(context, 'good'.tr(), distribution[3] ?? 0.0),
                  SizedBox(height: 4.h),
                  _buildBarRow(
                      context, 'acceptable'.tr(), distribution[2] ?? 0.0),
                  SizedBox(height: 4.h),
                  _buildBarRow(context, 'weak'.tr(), distribution[1] ?? 0.0),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarRow(BuildContext context, String label, double percentage) {
    return Row(
      children: [
        SizedBox(
          width: 50.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: context.textGrey),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: context.textDark,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 30.w,
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: TextStyle(fontSize: 11.sp, color: context.textGrey),
          ),
        ),
      ],
    );
  }
}

class ReviewCardWidget extends StatelessWidget {
  final ReviewEntity review;

  const ReviewCardWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.w,
                    backgroundColor: context.primaryColor,
                    backgroundImage: NetworkImage(review
                        .userAvatar), // Assuming network image or handle local
                    onBackgroundImageError: (_, __) {},
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    review.userName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                review.date,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: context.textGrey,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating.round() ? Icons.star : Icons.star_border,
                color: context.primaryColor,
                size: 14,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13.sp,
              color: context.textDark,
              height: 1.5.h,
            ),
          ),
          if (review.attachedImage != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                review.attachedImage!,
                height: 100.h,
                width: 100.w,
                fit: BoxFit.cover,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.thumb_up_alt_outlined,
                  size: 16, color: context.textGrey),
              SizedBox(width: 4.w),
              Text(
                'مفيدة (${review.likes})',
                style: TextStyle(fontSize: 12.sp, color: context.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
