import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:kdx/features/checkout/presentation/blocs/checkout_bloc.dart';
import 'package:kdx/features/checkout/presentation/blocs/checkout_event.dart';
import 'package:kdx/features/checkout/presentation/blocs/checkout_state.dart';
import 'package:kdx/features/checkout/domain/usecases/checkout_usecases.dart';
import 'package:kdx/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:kdx/features/checkout/domain/entities/checkout_entities.dart';
import 'package:kdx/core/error/failures.dart';

// ── Stub repository ───────────────────────────────────────────────
class _StubCheckoutRepository implements CheckoutRepository {
  final Map<String, dynamic> submitResponse;
  _StubCheckoutRepository(this.submitResponse);

  @override
  Future<Either<Failure, List<SavedAddressEntity>>> getAddresses() async =>
      const Right([]);

  @override
  Future<Either<Failure, SavedAddressEntity>> addAddress(
          SavedAddressEntity address) async =>
      Right(address);

  @override
  Future<Either<Failure, SavedAddressEntity>> editAddress(
          int id, SavedAddressEntity address) async =>
      Right(address);

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitCheckout(
          Map<String, dynamic> data) async =>
      Right(submitResponse);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCheckoutData() async =>
      const Right({});
}

// ── Helper: build a bloc with a given submit response ─────────────
CheckoutBloc _makeBloc(Map<String, dynamic> submitResponse) {
  final repo = _StubCheckoutRepository(submitResponse);
  return CheckoutBloc(
    getAddressesUseCase: GetAddressesUseCase(repo),
    addAddressUseCase: AddAddressUseCase(repo),
    submitCheckoutUseCase: SubmitCheckoutUseCase(repo),
    getCheckoutDataUseCase: GetCheckoutDataUseCase(repo),
    editAddressUseCase: EditAddressUseCase(repo),
  );
}

// ─────────────────────────────────────────────────────────────────
void main() {
  group('CheckoutBloc Payment Routing Tests', () {
    test('emits CheckoutRedirectToPayment for paytabs redirect', () async {
      final bloc = _makeBloc({
        'type': 'redirect',
        'payment_url':
            'https://backend.com/payments/paytabs/pay?order_number=123',
        'order_number': '123',
      });

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CheckoutLoading>(),
          isA<CheckoutRedirectToPayment>(),
        ]),
      );

      bloc.add(const CheckoutSubmitRequested({'payment_gateway': 'paytabs'}));
    });

    test('emits CheckoutSubmitted when no redirect url', () async {
      final bloc = _makeBloc({
        'success': true,
        'message': 'تم إنشاء الطلب بنجاح',
        'order_number': '456',
      });

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CheckoutLoading>(),
          isA<CheckoutSubmitted>(),
        ]),
      );

      bloc.add(const CheckoutSubmitRequested({'payment_gateway': 'paytabs'}));
    });

    test('emits CheckoutNativePaymentInit for Apple Pay', () async {
      final bloc = _makeBloc({
        'type': 'redirect',
        'payment_url':
            'https://backend.com/payments/applepay/pay?order_number=789',
        'order_number': '789',
      });

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CheckoutLoading>(),
          isA<CheckoutNativePaymentInit>(),
        ]),
      );

      bloc.add(const CheckoutSubmitRequested({'payment_gateway': 'applepay'}));
    });
  });
}
