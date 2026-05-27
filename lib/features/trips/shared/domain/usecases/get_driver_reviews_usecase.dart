import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_review_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/driver_repository.dart';

class GetDriverReviewsParams {
  const GetDriverReviewsParams({required this.driverId});

  final String driverId;
}

class GetDriverReviewsUseCase
    extends UseCase<List<DriverReviewEntity>, GetDriverReviewsParams> {
  GetDriverReviewsUseCase(this._repository);

  final DriverRepository _repository;

  @override
  Future<Either<Failure, List<DriverReviewEntity>>> call(
    GetDriverReviewsParams params,
  ) async {
    try {
      final reviews = await _repository.getReviews(params.driverId);
      return Right(reviews);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
