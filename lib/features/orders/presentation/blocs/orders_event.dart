import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersRequested extends OrdersEvent {
  const OrdersRequested();
}

class OrderDetailRequested extends OrdersEvent {
  final String orderNumber;

  const OrderDetailRequested({required this.orderNumber});

  @override
  List<Object?> get props => [orderNumber];
}

class OrderCancelRequested extends OrdersEvent {
  final String orderId;

  const OrderCancelRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderReviewSubmitted extends OrdersEvent {
  final String orderId;
  final String productId;
  final int rating;
  final String comment;

  const OrderReviewSubmitted({
    required this.orderId,
    required this.productId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [orderId, productId, rating, comment];
}

class OrderInvoiceRequested extends OrdersEvent {
  final String orderNumber;

  const OrderInvoiceRequested({required this.orderNumber});

  @override
  List<Object?> get props => [orderNumber];
}
