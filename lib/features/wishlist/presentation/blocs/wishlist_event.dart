import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class WishlistRequested extends WishlistEvent {
  const WishlistRequested();
}

class WishlistToggleItemRequested extends WishlistEvent {
  final String productId;

  const WishlistToggleItemRequested({required this.productId});

  @override
  List<Object?> get props => [productId];
}
