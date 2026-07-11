import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/order_repository.dart';

class DownloadInvoiceUseCase {
  final OrderRepository repository;

  DownloadInvoiceUseCase(this.repository);

  Future<Either<Failure, String>> call(String orderNumber) async {
    return await repository.downloadInvoice(orderNumber);
  }
}
