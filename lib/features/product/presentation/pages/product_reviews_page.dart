import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/review_entity.dart';
import '../widgets/review_widgets.dart';

class ProductReviewsPage extends StatelessWidget {
  final List<ReviewEntity> reviews;
  final Map<int, double> ratingDistribution;
  final double averageRating;
  final int totalReviews;

  const ProductReviewsPage({
    super.key,
    required this.reviews,
    required this.ratingDistribution,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: context.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleSpacing: 0,
          title: Text(
            'التقييمات ($totalReviews)',
            style: TextStyle(
              color: context.textDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              ReviewDistributionWidget(
                distribution: ratingDistribution,
                averageRating: averageRating,
                totalReviews: totalReviews,
              ),
              SizedBox(height: 32.h),
              if (reviews.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      'there_are_no_reviews'.tr(),
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: context.textGrey,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                )
              else
                ...reviews.map((r) => ReviewCardWidget(review: r)),
            ],
          ),
        ),
      ),
    );
  }
}
