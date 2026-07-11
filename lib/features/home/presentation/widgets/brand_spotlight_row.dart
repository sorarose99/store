import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/brand_entity.dart';
import 'package:kdx/core/constants/colors.dart';

class BrandSpotlightRow extends StatelessWidget {
  final List<BrandEntity> brands;

  const BrandSpotlightRow({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: brands.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (ctx, i) => _BrandCard(brand: brands[i]),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandEntity brand;
  const _BrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 110.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                brand.imageAsset,
                width: 110.w,
                height: 130.h,
                fit: BoxFit.cover,
              ),
            ),
            // gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 6.h,
              right: 6.w,
              left: 6.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    brand.name,
                    style: TextStyle(
                      color: context.backgroundColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'خصم ${brand.discountLabel}',
                    style: TextStyle(
                      color: context.primaryColor,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
