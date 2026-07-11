import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/cart_repository.dart';

class UpdateBreakdownUseCase {
  final CartRepository repository;

  UpdateBreakdownUseCase(this.repository);

  Future<Either<Failure, void>> call(
      String productId, List<Map<String, dynamic>> breakdown) async {
    return await repository.updateBreakdown(productId, breakdown);
  }
}
