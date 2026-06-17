import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ReviewCardEntity {
  final String userName;
  final String date;
  final double rating;
  final String text;
  final List<String> imageUrls;

  const ReviewCardEntity({
    required this.userName,
    required this.date,
    required this.rating,
    required this.text,
    required this.imageUrls,
  });
}

const _mockReviews = [
  ReviewCardEntity(
    userName: 'محمد خالد',
    date: '12/9/2023',
    rating: 5,
    text: 'جودة فوق المتوقع، والتفاصيل مرتبة من أول نظرة. أنصح به بشدة لكل من يبحث عن التميز والأناقة.',
    imageUrls: ['assets/images/cat_fashion.png'],
  ),
  ReviewCardEntity(
    userName: 'مها حسان',
    date: '10/9/2023',
    rating: 4,
    text: 'بسيط، عملي، ويؤدي الغرض بدون أي تعقيد. صراحة أعجبني جداً وسأكرر الشراء باللون الآخر.',
    imageUrls: ['assets/images/cat_fashion.png'],
  ),
];

class ReviewsDetailPage extends StatelessWidget {
  const ReviewsDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'التقييمات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rating Breakdown card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    // Big average text
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Text(
                            '4.8',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < 4 ? Icons.star : Icons.star_half,
                                color: const Color(0xFFFFCC00),
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'بناءً على 128 تقييم',
                            style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 100, color: const Color(0xFFEEEEEE)),
                    const SizedBox(width: 16),
                    // Stars progress list
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildStarProgressRow('5 نجوم', 0.85),
                          _buildStarProgressRow('4 نجوم', 0.10),
                          _buildStarProgressRow('3 نجوم', 0.03),
                          _buildStarProgressRow('نجمتان', 0.01),
                          _buildStarProgressRow('نجمة واحدة', 0.01),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Reviews Header
              const Text(
                'آراء العملاء',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Reviews List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mockReviews.length,
                separatorBuilder: (context, index) => const Divider(height: 28, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final review = _mockReviews[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review.userName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            review.date,
                            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Stars
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            color: i < review.rating ? const Color(0xFFFFCC00) : const Color(0xFFE5E5EA),
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.text,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textDark,
                          height: 1.5,
                        ),
                      ),
                      if (review.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: review.imageUrls.length,
                            itemBuilder: (context, i) => Container(
                              margin: const EdgeInsets.only(left: 8),
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: AssetImage(review.imageUrls[i]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarProgressRow(String starLabel, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(starLabel, style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: const Color(0xFFE5E5EA),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFCC00)),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
