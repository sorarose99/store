import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:kdx/core/network/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/home_data_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/banner_model.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, HomeDataEntity>> getHomeData() async {
    try {
      final data = await remoteDataSource.fetchHomeData();
      developer.log('HomeData received, beginning parsing...',
          name: 'HomeRepository');

      final bannerObj = data['banner'];
      final banners = bannerObj != null
          ? [BannerModel.fromJson(bannerObj as Map<String, dynamic>)]
          : <BannerModel>[];

      final categories = (data['categories'] as List<dynamic>?)
              ?.map(
                  (e) => CategoryModel.fromJsonSafe(e as Map<String, dynamic>))
              .whereType<CategoryModel>()
              .toList() ??
          [];

      var products = (data['new_products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJsonSafe(e as Map<String, dynamic>))
              .whereType<ProductModel>()
              .toList() ??
          [];

      final brands = <BrandModel>[];

      final flashSaleProducts = <ProductModel>[];

      var trendingProducts = (data['featured_products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJsonSafe(e as Map<String, dynamic>))
              .whereType<ProductModel>()
              .toList() ??
          [];

      // Fetch from /categories to get more categories (up to 15)
      developer.log('Fetching /categories for expanded top menu',
          name: 'HomeRepository');
      try {
        if (remoteDataSource is HomeRemoteDataSourceImpl) {
          final catData = await (remoteDataSource as HomeRemoteDataSourceImpl)
              .apiClient
              .get(ApiEndpoints.categories);
          final dataMap = catData.data;
          if (dataMap is Map && dataMap['categories'] != null) {
            final categoriesData = dataMap['categories'];
            List<dynamic> catsList = [];
            if (categoriesData is Map && categoriesData['data'] is List) {
              catsList = categoriesData['data'] as List<dynamic>;
            } else if (categoriesData is List) {
              catsList = categoriesData;
            }

            final fetchedCategories = catsList
                .map((e) =>
                    CategoryModel.fromJsonSafe(e as Map<String, dynamic>))
                .whereType<CategoryModel>()
                .where((c) =>
                    c.parentId == null ||
                    c.parentId!.isEmpty) // Ensure main categories
                .take(15)
                .toList();
            if (fetchedCategories.isNotEmpty) {
              categories.clear();
              categories.addAll(fetchedCategories);
            }
          }
        }
      } catch (e) {
        developer.log('Categories fetch failed: $e', name: 'HomeRepository');
      }

      // Fetch from /api/shop to get brands, extra banner, and fallback products
      developer.log(
          'Fetching /shop to get brands, extra banner, and fallback products',
          name: 'HomeRepository');
      try {
        if (remoteDataSource is HomeRemoteDataSourceImpl) {
          final shopData = await (remoteDataSource as HomeRemoteDataSourceImpl)
              .apiClient
              .get(ApiEndpoints.shop);
          if (shopData.data is Map) {
            final shopMap = shopData.data as Map<String, dynamic>;

            // Extract Brands
            if (shopMap['brands'] != null) {
              final brandsList = (shopMap['brands'] as List<dynamic>)
                  .map(
                      (e) => BrandModel.fromJsonSafe(e as Map<String, dynamic>))
                  .whereType<BrandModel>()
                  .toList();
              brands.addAll(brandsList);
            }

            // Extract Extra Banner
            if (shopMap['banner'] != null) {
              final shopBanner = BannerModel.fromJson(
                  shopMap['banner'] as Map<String, dynamic>);
              banners.add(shopBanner);
            }

            // Robust Fallback for Products
            if (shopMap['products'] != null) {
              final shopProductsData = shopMap['products'];
              if (shopProductsData is Map && shopProductsData['data'] is List) {
                final fallbackProducts = (shopProductsData['data']
                        as List<dynamic>)
                    .map((e) =>
                        ProductModel.fromJsonSafe(e as Map<String, dynamic>))
                    .whereType<ProductModel>()
                    .toList();

                // Do not shuffle so products match backend order

                // Extract flash sale (products with sale price)
                final saleProducts =
                    fallbackProducts.where((p) => p.isSale).toList();
                flashSaleProducts.addAll(saleProducts);
                if (flashSaleProducts.isEmpty && fallbackProducts.isNotEmpty) {
                  flashSaleProducts.addAll(fallbackProducts.take(8));
                }

                if (products.isEmpty && fallbackProducts.isNotEmpty) {
                  products = fallbackProducts.take(8).toList();
                }

                if (trendingProducts.isEmpty && fallbackProducts.isNotEmpty) {
                  // If we don't have enough featured from backend, use some random ones
                  trendingProducts = fallbackProducts
                      .where((p) => p.featured || p.isNew)
                      .take(8)
                      .toList();
                  if (trendingProducts.isEmpty) {
                    trendingProducts.addAll(fallbackProducts.take(8));
                  } else if (trendingProducts.length < 4) {
                    trendingProducts.addAll(fallbackProducts
                        .where((p) => !trendingProducts.contains(p))
                        .take(8 - trendingProducts.length));
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        developer.log('Shop fetch failed: $e', name: 'HomeRepository');
      }

      // Final fallback to ensure UI is never empty
      if (flashSaleProducts.isEmpty) flashSaleProducts.addAll(products);
      if (trendingProducts.isEmpty) trendingProducts.addAll(products);
      if (products.isEmpty) products.addAll(trendingProducts);

      developer.log(
          'Parsed successfully: ${categories.length} categories, ${products.length} products, ${trendingProducts.length} trending',
          name: 'HomeRepository');

      DateTime? flashSaleEndDate;
      if (banners.isNotEmpty && banners.first.endDate != null) {
        flashSaleEndDate = banners.first.endDate;
      }

      return Right(HomeDataEntity(
        banners: banners,
        categories: categories,
        products: products,
        brands: brands,
        flashSaleProducts: flashSaleProducts,
        trendingProducts: trendingProducts,
        flashSaleEndDate: flashSaleEndDate,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
