import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/home_data_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeDataEntity>> getHomeData();
}
