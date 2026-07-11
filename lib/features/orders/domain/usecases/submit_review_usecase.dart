import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/order_repository.dart';

class SubmitReviewUseCase {
  final OrderRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String productId,
    required int rating,
    required String comment,
  }) async {
    return await repository.submitReview(orderId, productId, rating, comment);
  }
}
