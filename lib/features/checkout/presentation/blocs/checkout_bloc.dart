import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/checkout_usecases.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final GetAddressesUseCase getAddressesUseCase;
  final AddAddressUseCase addAddressUseCase;
  final SubmitCheckoutUseCase submitCheckoutUseCase;

  final GetCheckoutDataUseCase getCheckoutDataUseCase;
  final EditAddressUseCase editAddressUseCase;

  CheckoutBloc({
    required this.getAddressesUseCase,
    required this.addAddressUseCase,
    required this.submitCheckoutUseCase,
    required this.getCheckoutDataUseCase,
    required this.editAddressUseCase,
  }) : super(CheckoutInitial()) {
    on<CheckoutAddressesRequested>(_onCheckoutAddressesRequested);
    on<CheckoutAddressAdded>(_onCheckoutAddressAdded);
    on<CheckoutSubmitRequested>(_onCheckoutSubmitRequested);
    on<CheckoutDataRequested>(_onCheckoutDataRequested);
    on<CheckoutAddressEdited>(_onCheckoutAddressEdited);
  }

  Future<void> _onCheckoutAddressesRequested(
    CheckoutAddressesRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final result = await getAddressesUseCase();
    result.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (addresses) => emit(CheckoutAddressesLoaded(addresses)),
    );
  }

  Future<void> _onCheckoutAddressAdded(
    CheckoutAddressAdded event,
    Emitter<CheckoutState> emit,
  ) async {
    final result = await addAddressUseCase(event.address);
    result.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (_) => add(const CheckoutDataRequested()),
    );
  }

  Future<void> _onCheckoutSubmitRequested(
    CheckoutSubmitRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final result = await submitCheckoutUseCase(event.checkoutData);
    result.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (response) {
        if (response['type'] == 'redirect' && response['payment_url'] != null) {
          final paymentUrl = response['payment_url'].toString();
          final uri = Uri.tryParse(paymentUrl);

          // Try query param first, then top-level response field, then
          // last URL path segment (used by tamara/tabby backend routes).
          final orderNumber = uri?.queryParameters['order_number'] ??
              response['order_number']?.toString() ??
              (uri != null && uri.pathSegments.isNotEmpty
                  ? uri.pathSegments.last
                  : '');

          final gateway =
              event.checkoutData['payment_gateway']?.toString() ?? 'paytabs';

          // All gateways use the native SDK path during testing —
          // tamara calls createTamaraSession() directly in the UI layer,
          // tabby uses TabbySDK, and paytabs uses flutter_paytabs_bridge.
          if (gateway == 'tamara' ||
              gateway == 'tabby' ||
              gateway == 'paytabs' ||
              gateway == 'visa' ||
              gateway == 'mada' ||
              gateway == 'applepay') {
            emit(CheckoutNativePaymentInit(
              paymentUrl: paymentUrl,
              orderNumber: orderNumber,
              gateway: gateway,
            ));
          } else {
            emit(CheckoutRedirectToPayment(
              paymentUrl: paymentUrl,
              orderNumber: orderNumber,
              gateway: gateway,
            ));
          }
        } else {
          final orderNumber = response['order_number'] ?? '#KDX-UNKNOWN';
          emit(CheckoutSubmitted(orderNumber));
        }
      },
    );
  }

  Future<void> _onCheckoutDataRequested(
    CheckoutDataRequested event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final result = await getCheckoutDataUseCase();
    result.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (data) => emit(CheckoutDataLoaded(data)),
    );
  }

  Future<void> _onCheckoutAddressEdited(
    CheckoutAddressEdited event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    final result = await editAddressUseCase(event.id, event.address);
    result.fold(
      (failure) => emit(CheckoutError(failure.message)),
      (_) {
        emit(CheckoutAddressEditSuccess());
        add(const CheckoutDataRequested());
      },
    );
  }
}
