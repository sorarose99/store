import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/delivery_option.dart';

abstract class DeliveryOptionsRepository {
  Future<Either<Failure, List<DeliveryOption>>> getDeliveryOptions();
}
