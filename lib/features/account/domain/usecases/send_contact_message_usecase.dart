import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/account_repository.dart';

class SendContactMessageUseCase {
  final AccountRepository repository;

  SendContactMessageUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> data) async {
    return await repository.sendContactMessage(data);
  }
}
