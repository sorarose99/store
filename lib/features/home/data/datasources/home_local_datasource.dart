import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../models/product_model.dart';

/// Hard-coded local datasource — swap call sites for real API later.
abstract class HomeLocalDatasource {
  List<dynamic> getBanners();
  List<dynamic> getCategories();
  List<ProductModel> getProducts({String? categoryId});
  List<dynamic> getBrands();
  List<ProductModel> getFlashSaleProducts();
  List<ProductModel> getTrendingProducts();
}

class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  // ─── Banners ─────────────────────────────────────────────────────────────
  @override
  List<BannerEntity> getBanners() => [
        const BannerEntity(
          id: 'b1',
          imageAsset: 'assets/images/home_banner_new.png',
          title: 'كل ما تحتاجه في مكان واحد',
          subtitle: 'تسوق أفضل الماركات والمنتجات',
          ctaLabel: 'تسوقي الحين',
          targetCategoryId: 'cat_fashion',
        ),
        const BannerEntity(
          id: 'b2',
          imageAsset: 'assets/images/banner_2.png',
          title: 'أناقة بلا حدود',
          subtitle: 'أحدث التشكيلات العالمية',
          ctaLabel: 'اكتشفي الآن',
          targetCategoryId: 'cat_fashion',
        ),
        const BannerEntity(
          id: 'b3',
          imageAsset: 'assets/images/banner_3.png',
          title: 'تخفيضات حصرية',
          subtitle: 'تصل إلى ٥٠٪ خصم',
          ctaLabel: 'تسوقي الحين',
          targetCategoryId: 'cat_sale',
        ),
      ];

  // ─── Categories ───────────────────────────────────────────────────────────
  @override
  List<CategoryEntity> getCategories() => [
        const CategoryEntity(
          id: 'cat_all',
          name: 'الكل',
          imageAsset: 'assets/images/cat_fashion.png',
          isSelected: true,
        ),
        const CategoryEntity(
          id: 'cat_fashion',
          name: 'موضة',
          imageAsset: 'assets/images/cat_fashion.png',
        ),
        const CategoryEntity(
          id: 'cat_beauty',
          name: 'الجمال',
          imageAsset: 'assets/images/cat_beauty.png',
        ),
        const CategoryEntity(
          id: 'cat_sports',
          name: 'الرياضة',
          imageAsset: 'assets/images/cat_sports.png',
        ),
        const CategoryEntity(
          id: 'cat_abayas',
          name: 'العبايات',
          imageAsset: 'assets/images/cat_fashion.png',
        ),
        const CategoryEntity(
          id: 'cat_kids',
          name: 'الأطفال',
          imageAsset: 'assets/images/cat_fashion.png',
        ),
      ];

  // ─── Products ─────────────────────────────────────────────────────────────
  @override
  List<ProductModel> getProducts({String? categoryId}) {
    final all = _allProducts();
    if (categoryId == null || categoryId == 'cat_all') return all;
    return all.where((p) => p.categoryId == categoryId).toList();
  }

  @override
  List<ProductModel> getFlashSaleProducts() =>
      _allProducts().where((p) => p.isSale).take(6).toList();

  @override
  List<ProductModel> getTrendingProducts() =>
      _allProducts().where((p) => p.isNew).take(6).toList();

  // ─── Brands ───────────────────────────────────────────────────────────────
  @override
  List<BrandEntity> getBrands() => [
        const BrandEntity(
          id: 'br1',
          name: 'Zara',
          imageAsset: 'assets/images/cat_fashion.png',
          discountLabel: '٤٠٪',
        ),
        const BrandEntity(
          id: 'br2',
          name: 'Mango',
          imageAsset: 'assets/images/cat_beauty.png',
          discountLabel: '٣٠٪',
        ),
        const BrandEntity(
          id: 'br3',
          name: 'H&M',
          imageAsset: 'assets/images/cat_sports.png',
          discountLabel: '٢٥٪',
        ),
        const BrandEntity(
          id: 'br4',
          name: 'Forever New',
          imageAsset: 'assets/images/cat_fashion.png',
          discountLabel: '٣٥٪',
        ),
      ];

  // ─── Internal product seed data ───────────────────────────────────────────
  List<ProductModel> _allProducts() => [
        const ProductModel(
          id: 'p1',
          name: 'بلوزة شيفون أنيقة',
          brand: 'ستايلي',
          price: 59,
          originalPrice: 95,
          imageAsset: 'assets/images/cat_fashion.png',
          isSale: true,
          isFreeDelivery: true,
          discountLabel: 'بكرة',
          categoryId: 'cat_fashion',
          rating: 4.2,
          reviewCount: 128,
        ),
        const ProductModel(
          id: 'p2',
          name: 'شورت رياضي مرتفع',
          brand: 'جينجر بيسيكس',
          price: 39,
          imageAsset: 'assets/images/cat_sports.png',
          isNew: true,
          discountLabel: 'اليوم',
          categoryId: 'cat_sports',
          rating: 4.5,
          reviewCount: 87,
        ),
        const ProductModel(
          id: 'p3',
          name: 'حذاء سنيكرز كلاسيك',
          brand: 'اديداس',
          price: 499,
          imageAsset: 'assets/images/cat_sports.png',
          isFreeDelivery: true,
          categoryId: 'cat_sports',
          rating: 4.8,
          reviewCount: 342,
        ),
        const ProductModel(
          id: 'p4',
          name: 'باليه فلاتس ناعمة',
          brand: 'مانجو',
          price: 179,
          originalPrice: 249,
          imageAsset: 'assets/images/cat_fashion.png',
          isSale: true,
          discountLabel: 'اليوم',
          categoryId: 'cat_fashion',
          rating: 4.3,
          reviewCount: 56,
        ),
        const ProductModel(
          id: 'p5',
          name: 'بالتوه أحمر رسمي',
          brand: 'Forever New',
          price: 280,
          originalPrice: 400,
          imageAsset: 'assets/images/cat_fashion.png',
          isSale: true,
          isFreeDelivery: true,
          categoryId: 'cat_fashion',
          rating: 4.6,
          reviewCount: 201,
        ),
        const ProductModel(
          id: 'p6',
          name: 'فستان فلوي صيفي',
          brand: 'H&M',
          price: 259,
          originalPrice: 370,
          imageAsset: 'assets/images/cat_fashion.png',
          isSale: true,
          isFreeDelivery: true,
          categoryId: 'cat_fashion',
          rating: 4.1,
          reviewCount: 93,
        ),
        const ProductModel(
          id: 'p7',
          name: 'أحمر شفاه مات فاخر',
          brand: 'NYX',
          price: 45,
          imageAsset: 'assets/images/cat_beauty.png',
          isNew: true,
          categoryId: 'cat_beauty',
          rating: 4.7,
          reviewCount: 415,
        ),
        const ProductModel(
          id: 'p8',
          name: 'كريم أساس طبيعي',
          brand: 'Charlotte Tilbury',
          price: 189,
          imageAsset: 'assets/images/cat_beauty.png',
          isNew: true,
          isFreeDelivery: true,
          categoryId: 'cat_beauty',
          rating: 4.9,
          reviewCount: 632,
        ),
        const ProductModel(
          id: 'p9',
          name: 'عباية مطرزة فاخرة',
          brand: 'دار نمشي',
          price: 890,
          originalPrice: 1200,
          imageAsset: 'assets/images/cat_fashion.png',
          isSale: true,
          isFreeDelivery: true,
          categoryId: 'cat_abayas',
          rating: 4.9,
          reviewCount: 178,
        ),
        const ProductModel(
          id: 'p10',
          name: 'حقيبة كروس بودي',
          brand: 'Milano',
          price: 320,
          imageAsset: 'assets/images/cat_fashion.png',
          isNew: true,
          categoryId: 'cat_fashion',
          rating: 4.4,
          reviewCount: 112,
        ),
      ];
}
