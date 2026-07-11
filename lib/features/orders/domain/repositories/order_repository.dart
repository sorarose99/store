import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders();
  Future<Either<Failure, OrderEntity>> getOrderDetail(String orderNumber);
  Future<Either<Failure, void>> cancelOrder(String orderId);
  Future<Either<Failure, void>> submitReview(
      String orderId, String productId, int rating, String comment);
  Future<Either<Failure, String>> downloadInvoice(String orderNumber);
}
