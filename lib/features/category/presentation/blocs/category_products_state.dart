import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product_entity.dart';

abstract class CategoryProductsState extends Equatable {
  const CategoryProductsState();

  @override
  List<Object?> get props => [];
}

class CategoryProductsInitial extends CategoryProductsState {}

class CategoryProductsLoading extends CategoryProductsState {}

class CategoryProductsLoaded extends CategoryProductsState {
  final List<ProductEntity> products;

  const CategoryProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class CategoryProductsError extends CategoryProductsState {
  final String message;

  const CategoryProductsError({required this.message});

  @override
  List<Object?> get props => [message];
}
