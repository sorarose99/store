import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/presentation/widgets/product_card.dart';

class CartEmptyPage extends StatelessWidget {
  const CartEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy products for recommendations
    final List<ProductEntity> recommendations = [
      const ProductEntity(
        id: 'r1',
        name: 'هودي رجالي',
        brand: 'KDX',
        price: 26.8,
        originalPrice: 30.0,
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
        name: 'قميص شيفون',
        brand: 'Brand',
        price: 26.8,
        originalPrice: 30.0,
        imageAsset: 'assets/images/cat_fashion.png',
        isNew: true,
        isSale: false,
        isFreeDelivery: false,
        rating: 4.8,
        reviewCount: 95,
        isWishlisted: false,
        categoryId: 'c2',
      ),
      const ProductEntity(
        id: 'r3',
        name: 'هودي رجالي',
        brand: 'KDX',
        price: 26.8,
        originalPrice: 30.0,
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
        id: 'r4',
        name: 'قميص شيفون',
        brand: 'Brand',
        price: 26.8,
        originalPrice: 30.0,
        imageAsset: 'assets/images/cat_fashion.png',
        isNew: true,
        isSale: false,
        isFreeDelivery: false,
        rating: 4.8,
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
            'السلة',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Custom Illustration (Shopping basket with X)
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.shopping_basket_outlined,
                    size: 80,
                    color: Color(0xFFC7C7CC),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFC7C7CC), width: 2),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFFC7C7CC),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Empty State Text
              const Text(
                'عذراً، لم يتم العثور على سلة التسوق',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          product: recommendations[index],
                        );
                      },
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
