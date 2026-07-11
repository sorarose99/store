import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product_entity.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<ProductEntity> products;
  final Set<String> wishlistedIds;

  WishlistLoaded({
    required this.products,
    Set<String>? wishlistedIds,
  }) : wishlistedIds = wishlistedIds ?? products.map((p) => p.id).toSet();

  bool isWishlisted(String productId) => wishlistedIds.contains(productId);

  @override
  List<Object?> get props => [products, wishlistedIds];
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}
