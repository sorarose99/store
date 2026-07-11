import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/delivery_option.dart';
import '../../domain/repositories/delivery_options_repository.dart';
import '../models/delivery_option_model.dart';

class DeliveryOptionsRepositoryImpl implements DeliveryOptionsRepository {
  // TODO: Inject Dio or ApiClient when the backend endpoint is ready
  DeliveryOptionsRepositoryImpl();

  @override
  Future<Either<Failure, List<DeliveryOption>>> getDeliveryOptions() async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock Data based on the provided image
      final List<DeliveryOption> mockData = [
        const DeliveryOptionModel(
          id: '1',
          type: 'free',
          title: 'delivery_options_free_title',
          description: 'delivery_options_free_desc',
          minDays: 25,
          maxDays: 40,
          price: 0.0,
        ),
        const DeliveryOptionModel(
          id: '2',
          type: 'fast',
          title: 'delivery_options_fast_title',
          description: 'delivery_options_fast_desc',
          minDays: 6,
          maxDays: 20,
          price: 50.0, // Example price, you can adjust
        ),
      ];

      return Right(mockData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
