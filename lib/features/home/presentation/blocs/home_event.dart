import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the home screen mounts.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// User tapped a category tab.
class CategorySelected extends HomeEvent {
  final String categoryId;
  const CategorySelected(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// User toggled wishlist on a product.
class WishlistToggled extends HomeEvent {
  final String productId;
  const WishlistToggled(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// User pulled-to-refresh.
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}
