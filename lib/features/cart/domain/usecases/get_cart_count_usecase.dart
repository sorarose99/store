import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/cart_repository.dart';

class GetCartCountUseCase {
  final CartRepository repository;

  GetCartCountUseCase(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getCartCount();
  }
}
