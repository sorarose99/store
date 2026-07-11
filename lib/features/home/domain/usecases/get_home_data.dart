import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/home_repository.dart';
import '../entities/home_data_entity.dart';

class GetHomeData {
  final HomeRepository repository;

  GetHomeData(this.repository);

  Future<Either<Failure, HomeDataEntity>> call() async {
    return await repository.getHomeData();
  }
}
