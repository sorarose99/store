import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/cart_usecases.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartUseCase updateCartUseCase;
  final UpdateBreakdownUseCase updateBreakdownUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ApplyCouponUseCase applyCouponUseCase;
  final RemoveCouponUseCase removeCouponUseCase;
  final UpdateShippingZoneUseCase updateShippingZoneUseCase;
  final GetCartCountUseCase getCartCountUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartUseCase,
    required this.updateBreakdownUseCase,
    required this.removeFromCartUseCase,
    required this.applyCouponUseCase,
    required this.removeCouponUseCase,
    required this.updateShippingZoneUseCase,
    required this.getCartCountUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial()) {
    on<CartRequested>(_onCartRequested);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemUpdated>(_onCartItemUpdated);
    on<CartItemOptimisticUpdated>(_onCartItemOptimisticUpdated);
    on<CartItemBreakdownUpdated>(_onCartItemBreakdownUpdated);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartCouponApplied>(_onCartCouponApplied);
    on<CartCouponRemoved>(_onCartCouponRemoved);
    on<CartShippingZoneUpdated>(_onCartShippingZoneUpdated);
    on<CartCountRequested>(_onCartCountRequested);
    on<CartCleared>(_onCartCleared);
  }

  Future<void> _onCartRequested(
    CartRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await getCartUseCase();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (summary) => emit(CartLoaded(
        items: summary.items,
        subtotal: summary.subtotal,
        taxAmount: summary.taxAmount,
        shippingCost: summary.shippingCost,
        couponDiscount: summary.discount,
        total: summary.total,
        zones: summary.zones,
        selectedZone: summary.selectedZone,
      )),
    );
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final result = await addToCartUseCase(
      event.productId,
      event.quantity,
      imageId: event.imageId,
      options: event.options,
    );
    await result.fold(
      (failure) async => emit(CartError(failure.message)),
      (_) async {
        final cartResult = await getCartUseCase();
        cartResult.fold(
          (failure) => emit(CartError(failure.message)),
          (summary) {
            if (summary.items.isNotEmpty) {
              final String resolvedSize = (event.sizeName != null && event.sizeName!.isNotEmpty)
                  ? event.sizeName!
                  : 'مقاس واحد'; // Default size to pass backend validation

              CartItemEntity? match;
              final expectedCartItemId = event.imageId != null 
                  ? '${event.productId}_img_${event.imageId}' 
                  : event.productId.toString();

              for (final item in summary.items) {
                if (item.id == expectedCartItemId) {
                  match = item;
                  break;
                }
              }
              
              if (match == null) {
                for (final item in summary.items.reversed) {
                  if (item.productId == event.productId) {
                    match = item;
                    break;
                  }
                }
              }

              match ??= summary.items.last;

              // Merge with previous breakdown if it existed
              List<Map<String, dynamic>> newBreakdown = [];
              if (state is CartLoaded) {
                final oldMatch = (state as CartLoaded).items.where((i) => i.id == match!.id).firstOrNull;
                if (oldMatch != null) {
                  newBreakdown = List<Map<String, dynamic>>.from(oldMatch.breakdown.map((e) => Map<String, dynamic>.from(e)));
                }
              }

              // Update or add the new size
              int sizeIndex = newBreakdown.indexWhere((b) => b['size_name'] == resolvedSize);
              if (sizeIndex >= 0) {
                newBreakdown[sizeIndex]['qty'] = (newBreakdown[sizeIndex]['qty'] as int) + event.quantity;
              } else {
                newBreakdown.add({'size_name': resolvedSize, 'qty': event.quantity});
              }

              // Optimistically update the item with the new breakdown
              final updatedItems = summary.items.map((item) {
                if (item.id == match!.id) {
                  return item.copyWith(breakdown: newBreakdown);
                }
                return item;
              }).toList();

              emit(CartLoaded(
                items: updatedItems,
                subtotal: summary.subtotal,
                taxAmount: summary.taxAmount,
                shippingCost: summary.shippingCost,
                couponDiscount: summary.discount,
                total: summary.total,
                zones: summary.zones,
                selectedZone: summary.selectedZone,
              ));

              if (match.id.isNotEmpty) {
                add(CartItemBreakdownUpdated(
                  productId: match.id,
                  breakdown: newBreakdown,
                ));
              }
            } else {
              // Fallback if summary items is empty for some reason
              emit(CartLoaded(
                items: summary.items,
                subtotal: summary.subtotal,
                taxAmount: summary.taxAmount,
                shippingCost: summary.shippingCost,
                couponDiscount: summary.discount,
                total: summary.total,
                zones: summary.zones,
                selectedZone: summary.selectedZone,
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onCartItemOptimisticUpdated(
    CartItemOptimisticUpdated event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedItems = currentState.items.map((item) {
        if (item.id == event.productId) {
          return item.copyWith(
            quantity: event.quantity,
            breakdown: event.breakdown ?? item.breakdown,
          );
        }
        return item;
      }).toList();
      emit(currentState.copyWith(items: updatedItems));
    }
  }

  Future<void> _onCartItemUpdated(
    CartItemUpdated event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    final previousItems = currentState is CartLoaded ? currentState.items : null;
    if (currentState is CartLoaded) {
      final result = await updateCartUseCase(event.productId, event.quantity, breakdown: event.breakdown);
      await result.fold(
        (failure) async {
          emit(CartError(failure.message, previousItems: previousItems));
          if (previousItems != null) {
            emit(currentState.copyWith(items: previousItems));
          }
        },
        (_) async {
          // Re-send the breakdown after the quantity update because the backend
          // wipes the breakdown array on every PUT /cart/update/{id} call.
          // Without this, checkout validation fails (requires breakdown to match quantity).
          if (event.breakdown != null && event.breakdown!.isNotEmpty) {
            final breakdownResult = await updateBreakdownUseCase(
              event.productId,
              event.breakdown!,
            );
            breakdownResult.fold((_) {}, (_) {});
          }
          add(const CartRequested());
        },
      );
    }
  }

  Future<void> _onCartItemBreakdownUpdated(
    CartItemBreakdownUpdated event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    final previousItems = currentState is CartLoaded ? currentState.items : null;
    if (currentState is CartLoaded) {
      final result =
          await updateBreakdownUseCase(event.productId, event.breakdown);
      result.fold(
        (failure) {
          emit(CartError(failure.message, previousItems: previousItems));
          if (previousItems != null) {
            emit(currentState.copyWith(items: previousItems));
          }
        },
        (_) => add(const CartRequested()),
      );
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedList = currentState.items
          .where((i) => i.id != event.productId)
          .toList();
      emit(currentState.copyWith(items: updatedList));

      final result = await removeFromCartUseCase(event.productId);
      result.fold(
        (failure) {
          emit(CartError(failure.message));
          add(const CartRequested());
        },
        (_) {},
      );
    }
  }

  Future<void> _onCartCouponApplied(
    CartCouponApplied event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final result = await applyCouponUseCase(event.code);
      result.fold(
        (failure) => emit(currentState.copyWith(
          actionError: failure.message,
        )),
        (discount) => emit(currentState.copyWith(
          appliedCouponCode: event.code,
          couponDiscount: discount,
          actionError: null,
          actionSuccess: 'promo_code_applied',
        )),
      );
    }
  }

  Future<void> _onCartCouponRemoved(
    CartCouponRemoved event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final result = await removeCouponUseCase();
      result.fold(
        (failure) => emit(CartError(failure.message)),
        (_) {
          emit(CartLoaded(
            items: currentState.items,
            appliedCouponCode: null,
            couponDiscount: 0.0,
          ));
        },
      );
    }
  }

  Future<void> _onCartShippingZoneUpdated(
    CartShippingZoneUpdated event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final result = await updateShippingZoneUseCase(event.zoneId);
      result.fold(
        (failure) => emit(CartError(failure.message)),
        (_) => add(const CartRequested()),
      );
    }
  }

  Future<void> _onCartCountRequested(
    CartCountRequested event,
    Emitter<CartState> emit,
  ) async {
    final result = await getCartCountUseCase();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (count) => emit(CartCountLoaded(count)),
    );
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    final result = await clearCartUseCase();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) => emit(const CartLoaded(items: [])),
    );
  }
}
