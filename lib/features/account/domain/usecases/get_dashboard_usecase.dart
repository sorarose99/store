import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/account_entities.dart';
import '../repositories/account_repository.dart';

class GetDashboardUseCase {
  final AccountRepository repository;

  GetDashboardUseCase(this.repository);

  Future<
          Either<Failure,
              ({DashboardStatsEntity stats, List<OrderEntity> recentOrders})>>
      call() async {
    return await repository.getDashboardData();
  }
}
