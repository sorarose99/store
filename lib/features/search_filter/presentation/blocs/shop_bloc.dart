import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product/domain/usecases/get_shop_products_usecase.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/data/models/product_model.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GetShopProductsUseCase getShopProductsUseCase;

  ShopBloc({required this.getShopProductsUseCase}) : super(ShopInitial()) {
    on<ShopProductsRequested>(_onShopProductsRequested);
    on<ShopProductsLoadMoreRequested>(_onShopProductsLoadMoreRequested);
  }

  /// Parses the paginated product list from the API response map.
  /// The Laravel API can return either:
  ///   { products: { data: [...], total: N, last_page: N } }  ← paginated
  ///   { products: [...] }                                      ← plain list
  _ParsedPage _parsePage(Map<String, dynamic> data) {
    final productsData = data['products'];
    List<ProductEntity> products = [];
    int? total;
    int? lastPage;
    int? currentPage;

    if (productsData != null && productsData is Map) {
      // Paginated Laravel response.
      if (productsData['data'] is List) {
        products = (productsData['data'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
      }
      total = _toInt(productsData['total']);
      lastPage = _toInt(productsData['last_page']);
      currentPage = _toInt(productsData['current_page']);
    } else if (productsData is List) {
      // Plain list response (no pagination metadata).
      products = productsData.map((e) => ProductModel.fromJson(e)).toList();
    }

    return _ParsedPage(
      products: products,
      total: total,
      lastPage: lastPage,
      currentPage: currentPage ?? 1,
    );
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// L8 fix: derive hasReachedMax from the API's own pagination metadata
  /// (`last_page`, `total`) rather than a hard-coded threshold.
  bool _calcHasReachedMax({
    required _ParsedPage page,
    required int requestedPage,
  }) {
    // If the API tells us the last page, use that.
    if (page.lastPage != null) {
      return requestedPage >= page.lastPage!;
    }
    // If we got a total, compare accumulated count.
    if (page.total != null && page.total! <= page.products.length) {
      return true;
    }
    // Final fallback: if fewer than 10 items returned, assume end of list.
    return page.products.isEmpty || page.products.length < 10;
  }

  Future<void> _onShopProductsRequested(
    ShopProductsRequested event,
    Emitter<ShopState> emit,
  ) async {
    emit(ShopLoading());

    final filters = Map<String, dynamic>.from(event.filters);
    filters['page'] = 1;

    final result = await getShopProductsUseCase(filters);

    result.fold(
      (failure) => emit(ShopError(message: failure.message)),
      (data) {
        final page = _parsePage(data);
        
        // --- Smart fallback logic for Camera Search ---
        // Strategy: if the compound query (e.g. "فستان مورد") returned nothing,
        // retry with ONLY the item type (first word) so the backend has the
        // best chance of returning any matching products.
        if (page.products.isEmpty && filters['is_camera'] == true) {
          final query = filters['search']?.toString().trim();
          if (query != null && query.isNotEmpty) {
            final parts = query.split(' ');
            if (parts.length > 1) {
              // Retry with only the first keyword (the item type).
              final itemOnlyQuery = parts.first;
              filters['search'] = itemOnlyQuery;
              // Clear is_camera flag so we don't loop infinitely on no results.
              filters.remove('is_camera');
              add(ShopProductsRequested(filters: filters));
              return;
            }
          }
        }

        final hasReachedMax =
            _calcHasReachedMax(page: page, requestedPage: 1);

        emit(ShopLoaded(
          products: page.products,
          categories: data['categories'] is List ? data['categories'] : [],
          brands: data['brands'] is List ? data['brands'] : [],
          sizes: data['sizes'] is List ? data['sizes'] : [],
          currentPage: 1,
          hasReachedMax: hasReachedMax,
          isFetchingMore: false,
          totalCount: page.total, // U4: expose total for the UI
        ));
      },
    );
  }

  Future<void> _onShopProductsLoadMoreRequested(
    ShopProductsLoadMoreRequested event,
    Emitter<ShopState> emit,
  ) async {
    final currentState = state;
    if (currentState is ShopLoaded &&
        !currentState.hasReachedMax &&
        !currentState.isFetchingMore) {
      emit(currentState.copyWith(isFetchingMore: true));

      final nextPage = currentState.currentPage + 1;
      final filters = Map<String, dynamic>.from(event.filters);
      filters['page'] = nextPage;

      final result = await getShopProductsUseCase(filters);

      result.fold(
        (failure) {
          emit(currentState.copyWith(isFetchingMore: false));
        },
        (data) {
          final page = _parsePage(data);
          final hasReachedMax =
              _calcHasReachedMax(page: page, requestedPage: nextPage);

          emit(currentState.copyWith(
            products: List.of(currentState.products)..addAll(page.products),
            currentPage: nextPage,
            hasReachedMax: hasReachedMax,
            isFetchingMore: false,
            totalCount: page.total ?? currentState.totalCount,
          ));
        },
      );
    }
  }
}

/// Internal data class for a parsed page response.
class _ParsedPage {
  final List<ProductEntity> products;
  final int? total;
  final int? lastPage;
  final int currentPage;

  const _ParsedPage({
    required this.products,
    required this.currentPage,
    this.total,
    this.lastPage,
  });
}
