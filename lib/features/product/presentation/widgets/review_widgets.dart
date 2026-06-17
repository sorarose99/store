import 'package:flutter/material.dart';
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
            const Text(
              'التقييمات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              '(أكثر من $totalReviews)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Side: Average Rating Number
            Column(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < averageRating.round() ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFCC00),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            // Right Side: Distribution Bars
            Expanded(
              child: Column(
                children: [
                  _buildBarRow(context, 'ممتاز', distribution[5] ?? 0.0),
                  const SizedBox(height: 4),
                  _buildBarRow(context, 'جيد جداً', distribution[4] ?? 0.0),
                  const SizedBox(height: 4),
                  _buildBarRow(context, 'جيد', distribution[3] ?? 0.0),
                  const SizedBox(height: 4),
                  _buildBarRow(context, 'مقبول', distribution[2] ?? 0.0),
                  const SizedBox(height: 4),
                  _buildBarRow(context, 'ضعيف', distribution[1] ?? 0.0),
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
          width: 50,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFEEEEEE),
                    backgroundImage: NetworkImage(review.userAvatar), // Assuming network image or handle local
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(width: 8),
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                review.date,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating.round() ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFCC00),
                size: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
          if (review.attachedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                review.attachedImage!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined, size: 16, color: AppColors.textGrey),
              const SizedBox(width: 4),
              Text(
                'مفيدة (${review.likes})',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
