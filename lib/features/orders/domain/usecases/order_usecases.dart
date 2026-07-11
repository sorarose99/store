import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
export 'cancel_order_usecase.dart';
export 'submit_review_usecase.dart';
export 'download_invoice_usecase.dart';

class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() async {
    return await repository.getOrders();
  }
}

class GetOrderDetailUseCase {
  final OrderRepository repository;

  GetOrderDetailUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(String orderNumber) async {
    return await repository.getOrderDetail(orderNumber);
  }
}
