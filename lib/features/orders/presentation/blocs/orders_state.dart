import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;

  const OrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderDetailLoaded extends OrdersState {
  final OrderEntity order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderActionLoading extends OrdersState {}

class OrderActionSuccess extends OrdersState {
  final String message;

  const OrderActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderActionError extends OrdersState {
  final String message;

  const OrderActionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderInvoiceLoaded extends OrdersState {
  final String invoiceUrl;

  const OrderInvoiceLoaded({required this.invoiceUrl});

  @override
  List<Object?> get props => [invoiceUrl];
}
