import 'package:equatable/equatable.dart';
import '../../../../features/home/domain/entities/product_entity.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<ProductEntity> products;
  final List<dynamic> categories;
  final List<dynamic> brands;
  final List<dynamic> sizes;
  final bool hasReachedMax;
  final int currentPage;
  final bool isFetchingMore;
  /// Total number of results from the server (for the result-count header — U4).
  final int? totalCount;

  const ShopLoaded({
    required this.products,
    required this.categories,
    required this.brands,
    required this.sizes,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.isFetchingMore = false,
    this.totalCount,
  });

  ShopLoaded copyWith({
    List<ProductEntity>? products,
    List<dynamic>? categories,
    List<dynamic>? brands,
    List<dynamic>? sizes,
    bool? hasReachedMax,
    int? currentPage,
    bool? isFetchingMore,
    int? totalCount,
  }) {
    return ShopLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      sizes: sizes ?? this.sizes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [
        products,
        categories,
        brands,
        sizes,
        hasReachedMax,
        currentPage,
        isFetchingMore,
        totalCount,
      ];
}

class ShopError extends ShopState {
  final String message;

  const ShopError({required this.message});

  @override
  List<Object?> get props => [message];
}
