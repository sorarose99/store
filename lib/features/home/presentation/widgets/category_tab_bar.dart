import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/category_entity.dart';
import '../../../../core/constants/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Namshe-style horizontal category filter chips
// Active = teal gradient pill · Inactive = white outlined pill
// ─────────────────────────────────────────────────────────────────────────────
class CategoryTabBar extends StatefulWidget {
  final List<CategoryEntity> categories;
  final ValueChanged<String> onCategorySelected;

  const CategoryTabBar({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (ctx, i) {
          final cat = widget.categories[i];
          return _CategoryChip(
            category: cat,
            onTap: () => widget.onCategorySelected(cat.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onTap;

  const _CategoryChip({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = category.isSelected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 0.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [context.primaryColor, context.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: context.border, width: 1.5.w),
          boxShadow: isSelected ? AppColors.tealGlowShadow : null,
        ),
        child: Center(
          child: Text(
            category.name,
            style: TextStyle(
              color: isSelected ? context.backgroundColor : context.textMid,
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Namshe Story-style Category Circles (used above banner on home)
// ─────────────────────────────────────────────────────────────────────────────
class StoryCategoryRow extends StatelessWidget {
  final List<StoryCategoryItem> items;

  const StoryCategoryRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (ctx, i) => _StoryCategoryItem(item: items[i]),
      ),
    );
  }
}

class StoryCategoryItem {
  final String label;
  final String imageAsset;
  final bool isActive;
  final VoidCallback? onTap;

  const StoryCategoryItem({
    required this.label,
    required this.imageAsset,
    this.isActive = false,
    this.onTap,
  });
}

class _StoryCategoryItem extends StatelessWidget {
  final StoryCategoryItem item;
  const _StoryCategoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circle with gradient border
          Container(
            width: 64.w,
            height: 64.h,
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: item.isActive
                  ? LinearGradient(
                      colors: [context.primaryColor, context.primaryDark],
                    )
                  : LinearGradient(
                      colors: [
                        context.border,
                        context.border.withAlpha(200),
                      ],
                    ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.backgroundColor,
              ),
              padding: EdgeInsets.all(2.w),
              child: ClipOval(
                child: item.imageAsset.startsWith('http')
                    ? Image.network(
                        item.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackIcon(),
                      )
                    : Image.asset(
                        item.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallbackIcon(),
                      ),
              ),
            ),
          ),
          SizedBox(height: 5.h),
          SizedBox(
            width: 64.w,
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: item.isActive ? FontWeight.w700 : FontWeight.w500,
                color: item.isActive ? context.primaryColor : context.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon() {
    final validFallbacks = [0, 3, 9];
    final index =
        validFallbacks[item.label.hashCode.abs() % validFallbacks.length];
    return Image.asset(
      'assets/images/fallback_cat_$index.png',
      fit: BoxFit.cover,
    );
  }
}
