import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/review_entity.dart';
import '../widgets/review_widgets.dart';

class ProductReviewsPage extends StatelessWidget {
  const ProductReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock rating distribution from image
    const Map<int, double> ratingDistribution = {
      5: 0.80,
      4: 0.20,
      3: 0.0,
      2: 0.0,
      1: 0.10,
    };

    // Mock expanded reviews based on image
    final List<ReviewEntity> allReviews = [
      const ReviewEntity(
        id: 'r1',
        userName: 'محمد خالد',
        userAvatar: 'https://i.pravatar.cc/100?img=11',
        rating: 5.0,
        date: '12/8/2023',
        comment: 'جودة تفوق التوقع، والتفاصيل مرتبة من أول نظرة. استخدمته أكثر من مرة ولسه كأنه جديد.',
        likes: 10,
        attachedImage: 'assets/images/cat_fashion.png', // Reusing placeholder for mockup
      ),
      const ReviewEntity(
        id: 'r2',
        userName: 'مها حسان',
        userAvatar: 'https://i.pravatar.cc/100?img=5',
        rating: 5.0,
        date: '15/8/2023',
        comment: 'بسيط عملي، ويؤدي الغرض بدون أي تعقيد. صراحة.. اختيار موفق، وما ندمت عليه.',
        likes: 56,
        attachedImage: 'assets/images/cat_fashion.png',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleSpacing: 0,
          title: const Text(
            'التقييمات (أكثر من 1000)',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.post_add_rounded, color: AppColors.textDark),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const ReviewDistributionWidget(
                distribution: ratingDistribution,
                averageRating: 4.28,
                totalReviews: 1000,
              ),
              const SizedBox(height: 32),
              ...allReviews.map((r) => ReviewCardWidget(review: r)).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
