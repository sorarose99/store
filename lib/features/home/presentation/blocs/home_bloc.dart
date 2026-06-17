import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_home_data.dart';
import '../../data/datasources/home_local_datasource.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeData getHomeData;
  final HomeLocalDatasource localDatasource;

  HomeBloc({
    required this.getHomeData,
    required this.localDatasource,
  }) : super(const HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<CategorySelected>(_onCategorySelected);
    on<WishlistToggled>(_onWishlistToggled);
    on<HomeRefreshed>(_onHomeRefreshed);
  }

  Future<void> _onHomeStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onHomeRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    final result = await getHomeData();
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(HomeLoaded(
        banners: data.banners,
        categories: data.categories,
        products: data.products,
        brands: data.brands,
        flashSaleProducts: data.flashSaleProducts,
        trendingProducts: data.trendingProducts,
      )),
    );
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    // Update selected state on categories list
    final updatedCategories = current.categories
        .map((c) => CategoryEntity(
              id: c.id,
              name: c.name,
              imageAsset: c.imageAsset,
              isSelected: c.id == event.categoryId,
            ))
        .toList();

    // Filter products by category
    final filteredProducts = localDatasource
        .getProducts(
          categoryId: event.categoryId == 'cat_all' ? null : event.categoryId,
        )
        .cast<ProductEntity>();

    emit(current.copyWith(
      categories: updatedCategories,
      products: filteredProducts,
      selectedCategoryId: event.categoryId,
    ));
  }

  void _onWishlistToggled(
    WishlistToggled event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    ProductEntity toggleWishlist(ProductEntity p) {
      if (p.id != event.productId) return p;
      return ProductEntity(
        id: p.id,
        name: p.name,
        brand: p.brand,
        price: p.price,
        originalPrice: p.originalPrice,
        imageAsset: p.imageAsset,
        isNew: p.isNew,
        isSale: p.isSale,
        isFreeDelivery: p.isFreeDelivery,
        rating: p.rating,
        reviewCount: p.reviewCount,
        isWishlisted: !p.isWishlisted,
        discountLabel: p.discountLabel,
        categoryId: p.categoryId,
      );
    }

    emit(current.copyWith(
      products: current.products.map(toggleWishlist).toList(),
      flashSaleProducts: current.flashSaleProducts.map(toggleWishlist).toList(),
      trendingProducts: current.trendingProducts.map(toggleWishlist).toList(),
    ));
  }
}
