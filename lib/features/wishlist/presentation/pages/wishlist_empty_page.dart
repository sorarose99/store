import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/presentation/widgets/product_card.dart';

class WishlistEmptyPage extends StatelessWidget {
  const WishlistEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy products for recommendations
    final List<ProductEntity> recommendations = [
      const ProductEntity(
        id: 'r1',
        name: 'جاكيت شتوي طويل',
        brand: 'KDX',
        price: 26.8,
        originalPrice: 30.8,
        imageAsset: 'assets/images/cat_fashion.png',
        isNew: false,
        isSale: true,
        isFreeDelivery: true,
        rating: 4.8,
        reviewCount: 150,
        isWishlisted: true,
        categoryId: 'c2',
      ),
      const ProductEntity(
        id: 'r2',
        name: 'هودي رجالي',
        brand: 'Brand',
        price: 26.8,
        originalPrice: 30.8,
        imageAsset: 'assets/images/cat_fashion.png',
        isNew: true,
        isSale: false,
        isFreeDelivery: false,
        rating: 4.9,
        reviewCount: 95,
        isWishlisted: false,
        categoryId: 'c2',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'المفضلة',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              
              // Custom Illustration (browser window with X mark and heart icon overlay)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Browser window outline
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Browser header bar
                          Container(
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0F1F5),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC7C7CC),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC7C7CC),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC7C7CC),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Icon(
                                Icons.favorite_border_rounded,
                                size: 40,
                                color: Color(0xFFD1D1D6),
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
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Color(0xFFE53935),
                          size: 16,
                        ),
                      ),
                    ),
                    // X mark overlay at bottom-left
                    Positioned(
                      bottom: -10,
                      left: -10,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textGrey,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              
              // Empty State Text
              const Text(
                'عذراً، لم يتم العثور على مفضلة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 24),
              
              // Go Shopping Button
              SizedBox(
                width: 140, // Match mockup button width
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to home shell
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'اذهب للتسوق',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Recommendations Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'توصيات لك',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Style horizontal side-by-side recommendation cards
                    SizedBox(
                      height: 270,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendations.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 44) / 2, // Perfect side-by-side fit
                            child: ProductCard(
                              product: recommendations[index],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
