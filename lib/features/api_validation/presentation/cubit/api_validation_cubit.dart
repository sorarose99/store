import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/validate_api_key_usecase.dart';
import 'api_validation_state.dart';

class ApiValidationCubit extends Cubit<ApiValidationState> {
  final ValidateApiKeyUseCase validateApiKeyUseCase;

  ApiValidationCubit({required this.validateApiKeyUseCase})
      : super(ApiValidationInitial());

  Future<void> testConnection() async {
    emit(ApiValidationLoading());

    final result = await validateApiKeyUseCase();

    result.fold(
      (failure) => emit(ApiValidationFailure(message: failure.message)),
      (_) => emit(ApiValidationSuccess()),
    );
  }
}
