import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/api_validation_repository.dart';
import '../datasources/api_validation_remote_datasource.dart';

class ApiValidationRepositoryImpl implements ApiValidationRepository {
  final ApiValidationRemoteDataSource remoteDataSource;

  ApiValidationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> validateApiKey() async {
    try {
      await remoteDataSource.validateApiKeyFromServer();
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message ?? 'Unauthorized'));
    } on ConnectionException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Connection error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
