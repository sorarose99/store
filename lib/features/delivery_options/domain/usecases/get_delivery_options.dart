import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/delivery_option.dart';
import '../repositories/delivery_options_repository.dart';

class GetDeliveryOptions implements UseCase<List<DeliveryOption>, NoParams> {
  final DeliveryOptionsRepository repository;

  GetDeliveryOptions(this.repository);

  @override
  Future<Either<Failure, List<DeliveryOption>>> call(NoParams params) async {
    return await repository.getDeliveryOptions();
  }
}
