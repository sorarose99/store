import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CartSummaryEntity>> getCart() async {
    try {
      final data = await remoteDataSource.getCart();
      List<CartItemEntity> items = [];

      final cartData = data['cart'];
      if (cartData is Map) {
        final itemsData = cartData['items'];
        if (itemsData is List) {
          items = itemsData.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (itemsData is Map) {
          items = itemsData.entries.map((e) {
            final val = e.value;
            if (val is Map) {
              return CartItemModel.fromJson({...val, 'cart_item_id': e.key} as Map<String, dynamic>);
            }
            return CartItemModel.fromJson(val as Map<String, dynamic>);
          }).toList();
        }
        
        // ── Parse zones (shipping options from backend) ──────────────────
        // Backend may return zones at top-level or inside cart object.
        // Each zone map contains: id, name, price/cost, description, etc.
        final rawZones = (data['zones'] ??
                cartData['zones'] ??
                data['shipping_zones'] ??
                data['shipping_methods']) as List?;

        final List<Map<String, dynamic>> zones = rawZones
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];

        // ── Parse selected zone id ────────────────────────────────────────
        // Backend may use 'selectedZone', 'selected_zone', 'selected_zone_id',
        // or the zone id may live inside cart data.
        int? selectedZone;
        final rawSelected = data['selectedZone'] ??
            data['selected_zone'] ??
            data['selected_zone_id'] ??
            cartData['selectedZone'] ??
            cartData['selected_zone'] ??
            cartData['selected_zone_id'];
        if (rawSelected != null) {
          selectedZone = rawSelected is int
              ? rawSelected
              : int.tryParse(rawSelected.toString());
        }
        // If still null, pick the first zone with is_selected/selected flag
        if (selectedZone == null && zones.isNotEmpty) {
          for (final z in zones) {
            final sel = z['is_selected'] ?? z['selected'] ?? z['active'];
            if (sel == true || sel == 1) {
              selectedZone = z['id'] is int
                  ? z['id'] as int
                  : int.tryParse(z['id'].toString());
              break;
            }
          }
        }

        return Right(CartSummaryEntity(
          items: items,
          subtotal: (cartData['subtotal'] as num?)?.toDouble() ?? 0.0,
          taxAmount: (cartData['tax_amount'] as num?)?.toDouble() ?? 0.0,
          shippingCost: (cartData['shipping_cost'] as num?)?.toDouble() ?? 0.0,
          discount: (cartData['discount'] as num?)?.toDouble() ?? 0.0,
          total: (cartData['total'] as num?)?.toDouble() ?? 0.0,
          zones: zones,
          selectedZone: selectedZone,
        ));
      }

      // Fallback if data structure is unexpected
      return Right(CartSummaryEntity(items: items));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(String productId, int quantity,
      {int? imageId, Map<String, dynamic>? options}) async {
    try {
      await remoteDataSource.addToCart(productId, quantity, imageId: imageId, options: options);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCart(
      String productId, int quantity, {List<Map<String, dynamic>>? breakdown}) async {
    try {
      await remoteDataSource.updateCart(productId, quantity, breakdown: breakdown);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBreakdown(
      String productId, List<Map<String, dynamic>> breakdown) async {
    try {
      await remoteDataSource.updateBreakdown(productId, breakdown);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String productId) async {
    try {
      await remoteDataSource.removeFromCart(productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> applyCoupon(String code) async {
    try {
      final response = await remoteDataSource.applyCoupon(code);
      final result = response['result'];
      final discount = (result is Map
          ? result['discount_num']
          : response['discount']) as num?;
      return Right(discount?.toDouble() ?? 0.0);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeCoupon() async {
    try {
      await remoteDataSource.removeCoupon();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShippingZone(int zoneId) async {
    try {
      await remoteDataSource.updateShippingZone(zoneId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCartCount() async {
    try {
      final count = await remoteDataSource.getCartCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await remoteDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
