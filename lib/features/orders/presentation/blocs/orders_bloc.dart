import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/order_usecases.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderDetailUseCase getOrderDetailUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final SubmitReviewUseCase submitReviewUseCase;
  final DownloadInvoiceUseCase downloadInvoiceUseCase;

  OrdersBloc({
    required this.getOrdersUseCase,
    required this.getOrderDetailUseCase,
    required this.cancelOrderUseCase,
    required this.submitReviewUseCase,
    required this.downloadInvoiceUseCase,
  }) : super(OrdersInitial()) {
    on<OrdersRequested>(_onOrdersRequested);
    on<OrderDetailRequested>(_onOrderDetailRequested);
    on<OrderCancelRequested>(_onOrderCancelRequested);
    on<OrderReviewSubmitted>(_onOrderReviewSubmitted);
    on<OrderInvoiceRequested>(_onOrderInvoiceRequested);
  }

  Future<void> _onOrdersRequested(
    OrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final result = await getOrdersUseCase();
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders: orders)),
    );
  }

  Future<void> _onOrderDetailRequested(
    OrderDetailRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());
    final result = await getOrderDetailUseCase(event.orderNumber);
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (order) => emit(OrderDetailLoaded(order: order)),
    );
  }

  Future<void> _onOrderCancelRequested(
    OrderCancelRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrderActionLoading());
    final result = await cancelOrderUseCase(event.orderId);
    result.fold(
      (failure) => emit(OrderActionError(message: failure.message)),
      (_) => emit(OrderActionSuccess(message: 'the_order_has_been'.tr())),
    );
  }

  Future<void> _onOrderReviewSubmitted(
    OrderReviewSubmitted event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrderActionLoading());
    final result = await submitReviewUseCase(
      orderId: event.orderId,
      productId: event.productId,
      rating: event.rating,
      comment: event.comment,
    );
    result.fold(
      (failure) => emit(OrderActionError(message: failure.message)),
      (_) =>
          emit(OrderActionSuccess(message: 'your_rating_has_been'.tr())),
    );
  }

  Future<void> _onOrderInvoiceRequested(
    OrderInvoiceRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrderActionLoading());
    final result = await downloadInvoiceUseCase(event.orderNumber);
    result.fold(
      (failure) => emit(OrderActionError(message: failure.message)),
      (url) => emit(OrderInvoiceLoaded(invoiceUrl: url)),
    );
  }
}
