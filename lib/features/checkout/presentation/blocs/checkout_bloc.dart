import 'dart:developer' as developer;
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
      (failure) {
        developer.log('[CheckoutBloc] Submit FAILED: ${failure.message}');
        emit(CheckoutError(failure.message));
      },
      (response) {
        // ── Log the full raw response so we can see exactly what the
        //    backend returns and map the fields correctly ──────────────
        developer.log('[CheckoutBloc] Submit response keys: ${response.keys.toList()}');
        developer.log('[CheckoutBloc] Submit response: $response');

        final gateway =
            event.checkoutData['payment_gateway']?.toString() ?? 'paytabs';

        // ── Resolve the URL to load in the WebView ────────────────────
        // The backend may return the redirect URL under several keys:
        //   • payment_url   (our expected field)
        //   • redirect_url  (PayTabs common pattern)
        //   • url           (generic)
        //   • data.url      (nested)
        final rawUrl = response['payment_url']?.toString() ??
            response['redirect_url']?.toString() ??
            response['url']?.toString() ??
            (response['data'] is Map
                ? (response['data']['url']?.toString() ??
                    response['data']['payment_url']?.toString() ??
                    response['data']['redirect_url']?.toString())
                : null);

        developer.log('[CheckoutBloc] Resolved payment URL: $rawUrl');
        developer.log('[CheckoutBloc] Response type field: ${response['type']}');

        // ── Resolve order number ──────────────────────────────────────
        String? orderNumber = response['order_number']?.toString() ??
            response['data']?['order_number']?.toString();

        if (orderNumber == null && rawUrl != null && rawUrl.isNotEmpty) {
          final uri = Uri.tryParse(rawUrl);
          if (uri != null) {
            orderNumber = uri.queryParameters['order_number'];
            if (orderNumber == null && uri.pathSegments.isNotEmpty) {
              // The backend routes define order_number as a path parameter,
              // e.g. /api/payments/tamara/pay/{order_number}
              orderNumber = uri.pathSegments.last;
            }
          }
        }
        orderNumber ??= '#KDX-UNKNOWN';

        developer.log('[CheckoutBloc] Order number: $orderNumber');

        // ── Decide flow ───────────────────────────────────────────────
        final hasRedirectUrl = rawUrl != null && rawUrl.isNotEmpty;
        // Consider it a redirect flow when:
        //   (a) type == 'redirect'  OR
        //   (b) a URL is present (backend may not always set type field)
        final isRedirect =
            response['type'] == 'redirect' || hasRedirectUrl;
        // Only PayTabs, Mada, and Apple Pay are handled natively via the SDKs in the mobile app.
        // Tabby and Tamara sessions are created securely on the server-side via the backend's
        // pay() controllers, so they are redirect flows.
        final isNativeGateway = gateway == 'paytabs' ||
            gateway == 'mada' ||
            gateway == 'applepay';

        if (isNativeGateway) {
          emit(CheckoutNativePaymentInit(
            paymentUrl: rawUrl ?? 'native://$gateway',
            orderNumber: orderNumber,
            gateway: gateway,
          ));
        } else if (isRedirect && hasRedirectUrl) {
          emit(CheckoutRedirectToPayment(
            paymentUrl: rawUrl,
            orderNumber: orderNumber,
            gateway: gateway,
          ));
        } else {
          developer.log('[CheckoutBloc] No redirect URL found — treating as direct submit');
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
