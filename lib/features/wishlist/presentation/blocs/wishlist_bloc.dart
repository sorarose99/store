import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/usecases/wishlist_usecases.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlistUseCase getWishlistUseCase;
  final ToggleWishlistUseCase toggleWishlistUseCase;

  WishlistBloc({
    required this.getWishlistUseCase,
    required this.toggleWishlistUseCase,
  }) : super(WishlistInitial()) {
    on<WishlistRequested>(_onWishlistRequested);
    on<WishlistToggleItemRequested>(_onWishlistToggleItemRequested);
  }

  Future<void> _onWishlistRequested(
    WishlistRequested event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
    final result = await getWishlistUseCase();
    result.fold(
      (failure) => emit(WishlistError(failure.message)),
      (products) => emit(WishlistLoaded(products: products)),
    );
  }

  Future<void> _onWishlistToggleItemRequested(
    WishlistToggleItemRequested event,
    Emitter<WishlistState> emit,
  ) async {
    final current = state;
    Set<String> ids = {};
    List<ProductEntity> products = [];

    if (current is WishlistLoaded) {
      ids = Set<String>.from(current.wishlistedIds);
      products = List<ProductEntity>.from(current.products);
    }

    final wasWishlisted = ids.contains(event.productId);
    if (wasWishlisted) {
      ids.remove(event.productId);
      products.removeWhere((p) => p.id == event.productId);
    } else {
      ids.add(event.productId);
    }

    emit(WishlistLoaded(
      products: products,
      wishlistedIds: ids,
    ));

    final result = await toggleWishlistUseCase(event.productId);
    result.fold(
      (failure) {
        emit(WishlistError(failure.message));
        add(const WishlistRequested());
      },
      (isAdded) {
        if (isAdded) {
          add(const WishlistRequested());
        }
      },
    );
  }
}
