import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kdx/features/category/domain/entities/nav_category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_subcategories_usecase.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetSubCategoriesUseCase getSubCategoriesUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.getSubCategoriesUseCase,
  }) : super(CategoryInitial()) {
    on<CategoryStarted>(_onCategoryStarted);
    on<MainCategorySelected>(_onMainCategorySelected);
    on<SubCategoryFetched>(_onSubCategoryFetched);
    on<CategoryLoadMoreMainCategoriesRequested>(
        _onCategoryLoadMoreMainCategoriesRequested);
  }

  Future<void> _onCategoryStarted(
    CategoryStarted event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    final result = await getCategoriesUseCase();
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (data) async {
        final String firstCatId;
        if (event.initialCategoryId != null &&
            data.mainCategories.any((c) => c.id == event.initialCategoryId)) {
          firstCatId = event.initialCategoryId!;
        } else {
          firstCatId = data.mainCategories.isNotEmpty
              ? data.mainCategories.first.id
              : '';
        }

        bool hasReachedMaxMain = data.mainCategories.isEmpty || data.mainCategories.length < 10; // Assuming API returns 15, we use < 10 for safety

        emit(CategoryLoaded(
          mainCategories: data.mainCategories,
          subCategories: data.subCategories,
          selectedCategoryId: firstCatId,
          currentMainPage: 1,
          hasReachedMaxMain: hasReachedMaxMain,
          isFetchingMoreMain: false,
        ));

        // Prefetch subcategories for ALL categories in the background
        if (data.mainCategories.isNotEmpty) {
          // We don't await the entire loop so we don't block the UI,
          // but we process them sequentially or in parallel
          Future.forEach(data.mainCategories, (cat) async {
            final subResult = await getSubCategoriesUseCase(cat.slug);
            subResult.fold(
              (_) {}, // Do nothing on error
              (subCategoriesList) {
                add(SubCategoryFetched(cat.id, subCategoriesList));
              },
            );
          });
        }
      },
    );
  }

  Future<void> _onMainCategorySelected(
    MainCategorySelected event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final current = state as CategoryLoaded;

      // Update selected category ID immediately for UI responsiveness
      emit(current.copyWith(selectedCategoryId: event.categoryId));

      // If we already fetched subcategories for this parent, skip
      if (current.subCategories.containsKey(event.categoryId) &&
          current.subCategories[event.categoryId]!.isNotEmpty) {
        return;
      }

      // Find the slug for the selected category
      final selectedCategory = current.mainCategories.firstWhere(
        (cat) => cat.id == event.categoryId,
      );

      // Fetch subcategories dynamically
      final result = await getSubCategoriesUseCase(selectedCategory.slug);

      result.fold(
        (failure) {
          // Keep current state on failure, maybe log error
        },
        (subCategoriesList) {
          // Fetch the LATEST state after the await
          if (state is CategoryLoaded) {
            final latestState = state as CategoryLoaded;
            final newSubCategories = Map<String, List<SubCategoryEntity>>.from(
                latestState.subCategories);
            newSubCategories[event.categoryId] = subCategoriesList;

            emit(latestState.copyWith(subCategories: newSubCategories));
          }
        },
      );
    }
  }

  void _onSubCategoryFetched(
    SubCategoryFetched event,
    Emitter<CategoryState> emit,
  ) {
    if (state is CategoryLoaded) {
      final latestState = state as CategoryLoaded;
      final newSubCategories =
          Map<String, List<SubCategoryEntity>>.from(latestState.subCategories);
      newSubCategories[event.categoryId] = event.subCategories;

      emit(latestState.copyWith(subCategories: newSubCategories));
    }
  }

  Future<void> _onCategoryLoadMoreMainCategoriesRequested(
    CategoryLoadMoreMainCategoriesRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (state is CategoryLoaded) {
      final current = state as CategoryLoaded;
      if (!current.hasReachedMaxMain && !current.isFetchingMoreMain) {
        emit(current.copyWith(isFetchingMoreMain: true));

        final nextPage = current.currentMainPage + 1;
        final result = await getCategoriesUseCase(page: nextPage);

        result.fold(
          (failure) {
            emit(current.copyWith(isFetchingMoreMain: false));
          },
          (data) {
            bool hasReachedMax = data.mainCategories.isEmpty || data.mainCategories.length < 10;
            
            final newMainCategories = List.of(current.mainCategories)
              ..addAll(data.mainCategories);

            emit(current.copyWith(
              mainCategories: newMainCategories,
              currentMainPage: nextPage,
              hasReachedMaxMain: hasReachedMax,
              isFetchingMoreMain: false,
            ));

            if (data.mainCategories.isNotEmpty) {
              Future.forEach(data.mainCategories, (cat) async {
                final subResult = await getSubCategoriesUseCase(cat.slug);
                subResult.fold(
                  (_) {},
                  (subCategoriesList) {
                    add(SubCategoryFetched(cat.id, subCategoriesList));
                  },
                );
              });
            }
          },
        );
      }
    }
  }
}
