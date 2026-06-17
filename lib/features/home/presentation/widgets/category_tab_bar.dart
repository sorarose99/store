import 'package:flutter/material.dart';
import 'package:store/features/home/domain/entities/category_entity.dart';
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
      height: 40,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 1.5),
          boxShadow: isSelected ? AppColors.tealGlowShadow : null,
        ),
        child: Center(
          child: Text(
            category.name,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMid,
              fontSize: 13,
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
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
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
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: item.isActive
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.border,
                        AppColors.border.withAlpha(200),
                      ],
                    ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: Image.asset(
                  item.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.category_outlined,
                        color: AppColors.primary, size: 28),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 64,
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    item.isActive ? FontWeight.w700 : FontWeight.w500,
                color:
                    item.isActive ? AppColors.primary : AppColors.textMid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


