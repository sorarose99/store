import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductDetailsUseCase getProductDetailsUseCase;

  ProductDetailsCubit({required this.getProductDetailsUseCase})
      : super(ProductDetailsInitial());

  Future<void> fetchProductDetails(String slug) async {
    emit(ProductDetailsLoading());
    final result = await getProductDetailsUseCase(slug);

    result.fold(
      (failure) => emit(ProductDetailsError(message: failure.message)),
      (productDetails) =>
          emit(ProductDetailsLoaded(productDetails: productDetails)),
    );
  }
}
