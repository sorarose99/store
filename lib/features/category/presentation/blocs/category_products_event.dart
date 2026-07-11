import 'package:equatable/equatable.dart';

abstract class CategoryProductsEvent extends Equatable {
  const CategoryProductsEvent();

  @override
  List<Object?> get props => [];
}

class CategoryProductsRequested extends CategoryProductsEvent {
  final String categorySlug;

  const CategoryProductsRequested({required this.categorySlug});

  @override
  List<Object?> get props => [categorySlug];
}
