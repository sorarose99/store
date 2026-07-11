import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, CategoryData>> call({int page = 1}) async {
    return await repository.getCategories(page: page);
  }
}
