import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/nav_category_entity.dart';
import '../../../search/presentation/pages/search_active_page.dart';
import '../../../search_filter/presentation/pages/product_grid_page.dart';

class CategoryNavigationPage extends StatefulWidget {
  const CategoryNavigationPage({super.key});

  @override
  State<CategoryNavigationPage> createState() => _CategoryNavigationPageState();
}

class _CategoryNavigationPageState extends State<CategoryNavigationPage> {
  // Centralized Mock Category Data Source
  final List<MainCategoryEntity> mainCategories = const [
    MainCategoryEntity(id: 'c1', name: 'ملابس نسائية'),
    MainCategoryEntity(id: 'c2', name: 'ملابس رجالية'),
    MainCategoryEntity(id: 'c3', name: 'شنط'),
    MainCategoryEntity(id: 'c4', name: 'أحذية واكسسوارات'),
    MainCategoryEntity(id: 'c5', name: 'ملابس نوم'),
    MainCategoryEntity(id: 'c6', name: 'لانجري'),
    MainCategoryEntity(id: 'c7', name: 'هدايا العيد'),
    MainCategoryEntity(id: 'c8', name: 'الماركات'),
  ];

  final Map<String, List<SubCategoryEntity>> subCategoriesData = {
    'c1': [
      const SubCategoryEntity(id: 's1', name: 'فساتين', imageAsset: 'assets/images/cat_dresses.png'),
      const SubCategoryEntity(id: 's2', name: 'تيشيرتات وبلايز', imageAsset: 'assets/images/cat_tops.png'),
      const SubCategoryEntity(id: 's3', name: 'تنانير', imageAsset: 'assets/images/cat_fashion.png'),
      const SubCategoryEntity(id: 's4', name: 'شورتات', imageAsset: 'assets/images/cat_sports.png'),
      const SubCategoryEntity(id: 's5', name: 'أطقم', imageAsset: 'assets/images/cat_latest.png'),
      const SubCategoryEntity(id: 's6', name: 'ملابس منزل', imageAsset: 'assets/images/cat_beauty.png'),
      const SubCategoryEntity(id: 's7', name: 'جينز', imageAsset: 'assets/images/cat_fashion.png'),
      const SubCategoryEntity(id: 's8', name: 'ملابس داخلية', imageAsset: 'assets/images/cat_dresses.png'),
    ],
    'c2': [
      const SubCategoryEntity(id: 's21', name: 'تيشيرتات', imageAsset: 'assets/images/cat_fashion.png'),
      const SubCategoryEntity(id: 's22', name: 'قمصان', imageAsset: 'assets/images/cat_fashion.png'),
      const SubCategoryEntity(id: 's23', name: 'بناطيل', imageAsset: 'assets/images/cat_sports.png'),
      const SubCategoryEntity(id: 's24', name: 'هوديز', imageAsset: 'assets/images/cat_fashion.png'),
    ],
    'c3': [
      const SubCategoryEntity(id: 's31', name: 'حقائب كتف', imageAsset: 'assets/images/cat_bags.png'),
      const SubCategoryEntity(id: 's32', name: 'حقائب ظهر', imageAsset: 'assets/images/cat_bags.png'),
      const SubCategoryEntity(id: 's33', name: 'محافظ', imageAsset: 'assets/images/cat_bags.png'),
    ],
  };

  String _selectedCategoryId = 'c1';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            const Divider(color: AppColors.border, height: 1, thickness: 1),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Right Sidebar (RTL) containing Main Categories
                  _buildSidebar(),

                  // Left Main Content Area containing Subcategories
                  _buildMainContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
        onPressed: () {
          // Navigates back or closes category browser if applicable
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchActivePage()),
          );
        },
        child: Container(
          height: 38,
          margin: const EdgeInsets.only(left: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: AppColors.textGrey, size: 20),
              SizedBox(width: 8),
              Text(
                'البحث عن الملابس',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textDark),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 105,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9FC),
        border: Border(left: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: ListView.builder(
        itemCount: mainCategories.length,
        itemBuilder: (context, index) {
          final category = mainCategories[index];
          final isSelected = category.id == _selectedCategoryId;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryId = category.id;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border(
                  right: BorderSide(
                    color: isSelected ? AppColors.textDark : Colors.transparent,
                    width: 3.5,
                  ),
                ),
              ),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Tajawal',
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.textDark : AppColors.textGrey,
                  height: 1.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    final subcategories = subCategoriesData[_selectedCategoryId] ?? [];
    final activeMainCategory = mainCategories.firstWhere((c) => c.id == _selectedCategoryId);

    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header of the current category
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                activeMainCategory.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),

            // Grid view of Subcategories
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.76,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 16,
                ),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  final subcat = subcategories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductGridPage(categoryName: subcat.name),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // Circular Thumbnail image container
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF2F3F8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipOval(
                              child: Image.asset(
                                subcat.imageAsset,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.style_outlined, color: AppColors.textGrey),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Title below the circle
                        Text(
                          subcat.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            fontFamily: 'Tajawal',
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
