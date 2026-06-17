import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onQuantityIncrease;
  final VoidCallback onQuantityDecrease;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityIncrease,
    required this.onQuantityDecrease,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isAvailable ? const Color(0xFFECEEF5) : const Color(0xFFFFCDD2),
          width: item.isAvailable ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image (3:4 ratio)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item.imageUrl,
                    width: 76,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 76,
                      height: 100,
                      color: const Color(0xFFF2F3F8),
                      child: const Icon(Icons.image_outlined, color: AppColors.textGrey, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Details (Center)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Size attribute
                      Text(
                        'المقاس: ${item.size}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Color attribute
                      Text(
                        'اللون: ${item.color}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Price (Red text in mockup)
                      Text(
                        '${item.price.toInt()} ر.س',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE53935), // Red price
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions & Stepper (Left)
                SizedBox(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Top Row: Share and Delete buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textGrey),
                            onPressed: onShare,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textGrey),
                            onPressed: onDelete,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                        ],
                      ),
                      // Bottom Row: Stepper quantity selector
                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E5EA), width: 1),
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Increase Quantity (+)
                            GestureDetector(
                              onTap: item.isAvailable ? onQuantityIncrease : null,
                              child: Container(
                                width: 28,
                                alignment: Alignment.center,
                                child: const Icon(Icons.add, size: 12, color: AppColors.textDark),
                              ),
                            ),
                            // Quantity display
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                            // Decrease Quantity (-)
                            GestureDetector(
                              onTap: item.isAvailable ? onQuantityDecrease : null,
                              child: Container(
                                width: 28,
                                alignment: Alignment.center,
                                child: const Icon(Icons.remove, size: 12, color: AppColors.textDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Alert warning for Out of Stock items
          if (!item.isAvailable)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE), // Soft red background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Text(
                'هذا المنتج لم يعد متوفراً. احذف المنتج لإتمام عملية الشراء',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFFC62828), // Deep red text
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
