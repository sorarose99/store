import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/account_repository.dart';

class SaveFcmTokenUseCase {
  final AccountRepository repository;

  SaveFcmTokenUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String token,
    required String deviceId,
    String? platform,
    String? deviceName,
  }) async {
    return await repository.saveFcmToken(
      token: token,
      deviceId: deviceId,
      platform: platform,
      deviceName: deviceName,
    );
  }
}
