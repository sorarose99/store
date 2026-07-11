import 'package:equatable/equatable.dart';
import '../../domain/entities/nav_category_entity.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryStarted extends CategoryEvent {
  final String? initialCategoryId;
  const CategoryStarted({this.initialCategoryId});

  @override
  List<Object?> get props => [initialCategoryId];
}

class MainCategorySelected extends CategoryEvent {
  final String categoryId;
  const MainCategorySelected(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SubCategoryFetched extends CategoryEvent {
  final String categoryId;
  final List<SubCategoryEntity> subCategories;

  const SubCategoryFetched(this.categoryId, this.subCategories);

  @override
  List<Object?> get props => [categoryId, subCategories];
}

class CategoryLoadMoreMainCategoriesRequested extends CategoryEvent {
  const CategoryLoadMoreMainCategoriesRequested();
}
