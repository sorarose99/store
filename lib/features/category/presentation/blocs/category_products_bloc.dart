import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_category_products_usecase.dart';
import 'category_products_event.dart';
import 'category_products_state.dart';

class CategoryProductsBloc
    extends Bloc<CategoryProductsEvent, CategoryProductsState> {
  final GetCategoryProductsUseCase getCategoryProductsUseCase;

  CategoryProductsBloc({required this.getCategoryProductsUseCase})
      : super(CategoryProductsInitial()) {
    on<CategoryProductsRequested>(_onCategoryProductsRequested);
  }

  Future<void> _onCategoryProductsRequested(
    CategoryProductsRequested event,
    Emitter<CategoryProductsState> emit,
  ) async {
    emit(CategoryProductsLoading());
    final result = await getCategoryProductsUseCase(event.categorySlug);

    result.fold(
      (failure) => emit(CategoryProductsError(message: failure.message)),
      (products) => emit(CategoryProductsLoaded(products: products)),
    );
  }
}
