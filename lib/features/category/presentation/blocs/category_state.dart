import 'package:equatable/equatable.dart';
import '../../domain/entities/nav_category_entity.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<MainCategoryEntity> mainCategories;
  final Map<String, List<SubCategoryEntity>> subCategories;
  final String selectedCategoryId;
  final int currentMainPage;
  final bool hasReachedMaxMain;
  final bool isFetchingMoreMain;

  const CategoryLoaded({
    required this.mainCategories,
    required this.subCategories,
    required this.selectedCategoryId,
    this.currentMainPage = 1,
    this.hasReachedMaxMain = false,
    this.isFetchingMoreMain = false,
  });

  CategoryLoaded copyWith({
    List<MainCategoryEntity>? mainCategories,
    Map<String, List<SubCategoryEntity>>? subCategories,
    String? selectedCategoryId,
    int? currentMainPage,
    bool? hasReachedMaxMain,
    bool? isFetchingMoreMain,
  }) {
    return CategoryLoaded(
      mainCategories: mainCategories ?? this.mainCategories,
      subCategories: subCategories ?? this.subCategories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      currentMainPage: currentMainPage ?? this.currentMainPage,
      hasReachedMaxMain: hasReachedMaxMain ?? this.hasReachedMaxMain,
      isFetchingMoreMain: isFetchingMoreMain ?? this.isFetchingMoreMain,
    );
  }

  @override
  List<Object?> get props => [
        mainCategories,
        subCategories,
        selectedCategoryId,
        currentMainPage,
        hasReachedMaxMain,
        isFetchingMoreMain,
      ];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
