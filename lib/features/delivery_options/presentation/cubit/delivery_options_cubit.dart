import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/delivery_option.dart';
import '../../domain/usecases/get_delivery_options.dart';
import 'delivery_options_state.dart';

class DeliveryOptionsCubit extends Cubit<DeliveryOptionsState> {
  final GetDeliveryOptions getDeliveryOptions;

  DeliveryOptionsCubit({required this.getDeliveryOptions})
      : super(DeliveryOptionsInitial());

  Future<void> fetchDeliveryOptions() async {
    emit(DeliveryOptionsLoading());

    final result = await getDeliveryOptions(NoParams());

    if (isClosed) return;

    result.fold(
      (failure) => emit(DeliveryOptionsError(failure.message)),
      (options) {
        // Default to the first option if none selected, or leave null
        emit(DeliveryOptionsLoaded(
          options: options,
          selectedOption: options.isNotEmpty ? options.first : null,
        ));
      },
    );
  }

  void selectOption(DeliveryOption option) {
    if (state is DeliveryOptionsLoaded) {
      final currentState = state as DeliveryOptionsLoaded;
      emit(currentState.copyWith(selectedOption: option));
    }
  }
}
