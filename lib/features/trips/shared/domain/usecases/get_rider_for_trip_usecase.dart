import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/rider_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/rider_repository.dart';

class GetRiderForTripParams {
  const GetRiderForTripParams({required this.riderId});

  final String riderId;
}

class GetRiderForTripUseCase
    extends UseCase<RiderEntity?, GetRiderForTripParams> {
  GetRiderForTripUseCase(this._repository);

  final RiderRepository _repository;

  @override
  Future<Either<Failure, RiderEntity?>> call(
    GetRiderForTripParams params,
  ) async {
    try {
      if (params.riderId.isEmpty) {
        return const Right(null);
      }
      final rider = await _repository.findById(params.riderId);
      return Right(rider);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
