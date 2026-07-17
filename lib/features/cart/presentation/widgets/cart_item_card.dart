import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../product/presentation/pages/product_details_page.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final void Function(String?) onQuantityIncrease;
  final void Function(String?) onQuantityDecrease;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final void Function(String?)? onEditSize;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityIncrease,
    required this.onQuantityDecrease,
    required this.onDelete,
    required this.onShare,
    this.onEditSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isAvailable ? context.primaryColor : context.errorColor,
          width: item.isAvailable ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: context.textDark.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                print('CartItemCard onTap: item.id=${item.id}, item.slug=${item.slug}, item.productId=${item.productId}');
                final identifier = item.slug.isNotEmpty ? item.slug : item.productId;
                if (identifier.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(slug: identifier),
                    ),
                  );
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image (3:4 ratio)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 76.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 76.w,
                        height: 100.h,
                        color: context.primaryColor,
                        child: Icon(Icons.image_outlined,
                            color: context.textGrey, size: 24),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),

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
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textDark,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        if (!item.isAvailable) ...[
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: context.errorColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: context.errorColor, width: 0.5),
                            ),
                            child: Text(
                              'out_of_stock'.tr(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: context.errorColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 6.h),
                        // Size attribute
                        if (item.size.isNotEmpty) ...[
                          Text(
                            '${'size_label'.tr()}: ${item.size}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: context.textGrey,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                        if (item.color.isNotEmpty) ...[
                          Text(
                            '${'color_label'.tr()}: ${item.color}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: context.textGrey,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                        if (item.breakdown.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          ...item.breakdown
                              .where((b) => (b['size_name']?.toString() ?? '') != '-')
                              .map((b) => Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${'size_label'.tr()} ${b['size_name']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: context.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Tajawal',
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Container(
                                      height: 24.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: context.primaryColor,
                                            width: 1.w),
                                        borderRadius: BorderRadius.circular(12),
                                        color: context.backgroundColor,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: item.isAvailable
                                                ? () => onQuantityIncrease(
                                                    b['size_name']
                                                            ?.toString() ??
                                                        '')
                                                : null,
                                            child: Container(
                                              width: 24.w,
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              child: Icon(Icons.add,
                                                  size: 10,
                                                  color: context.textDark),
                                            ),
                                          ),
                                          Text(
                                            '${b['qty']}',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: context.textDark,
                                              fontFamily: 'Tajawal',
                                            ),
                                          ),
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: item.isAvailable
                                                ? () => onQuantityDecrease(
                                                    b['size_name']
                                                            ?.toString() ??
                                                        '')
                                                : null,
                                            child: Container(
                                              width: 24.w,
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              child: Icon(Icons.remove,
                                                  size: 10,
                                                  color: context.textDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                        SizedBox(height: 12.h),
                        // Price (Red text in mockup)
                        Text(
                          '${item.price.toInt()} ﷼',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: context.primaryColor, // Red price
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions & Stepper (Left)
                  SizedBox(
                    height: 100.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Top Row: Share and Delete buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.share_outlined,
                                  size: 20, color: context.textGrey),
                              onPressed: onShare,
                              padding: EdgeInsets.all(8.w),
                            ),
                            SizedBox(width: 8.w),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  size: 20, color: context.textGrey),
                              onPressed: onDelete,
                              padding: EdgeInsets.all(8.w),
                            ),
                          ],
                        ),

                        // Bottom Row: Stepper quantity selector
                        // Stepper quantity selector only if there's no breakdown or just one size
                        if (item.breakdown.isEmpty ||
                            item.breakdown.length == 1)
                          Container(
                            height: 28.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: context.primaryColor, width: 1.w),
                              borderRadius: BorderRadius.circular(14),
                              color: context.backgroundColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: item.isAvailable
                                      ? () => onQuantityIncrease(null)
                                      : null,
                                  child: Container(
                                    width: 28.w,
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Icon(Icons.add,
                                        size: 12, color: context.textDark),
                                  ),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.textDark,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: item.isAvailable
                                      ? () => onQuantityDecrease(null)
                                      : null,
                                  child: Container(
                                    width: 28.w,
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Icon(Icons.remove,
                                        size: 12, color: context.textDark),
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
          ),

          // Alert warning for Out of Stock items
          if (!item.isAvailable)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: context.primaryColor, // Soft red background
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                'this_product_is_no'.tr(),
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color:
                      context.backgroundColor, // White text on teal background
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
