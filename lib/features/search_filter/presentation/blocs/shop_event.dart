import 'package:equatable/equatable.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

class ShopProductsRequested extends ShopEvent {
  final Map<String, dynamic> filters;

  const ShopProductsRequested({required this.filters});

  @override
  List<Object?> get props => [filters];
}

class ShopProductsLoadMoreRequested extends ShopEvent {
  final Map<String, dynamic> filters;

  const ShopProductsLoadMoreRequested({required this.filters});

  @override
  List<Object?> get props => [filters];
}
