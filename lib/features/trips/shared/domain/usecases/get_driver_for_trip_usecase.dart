import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/driver_repository.dart';

class GetDriverForTripParams {
  const GetDriverForTripParams({this.driverName});

  final String? driverName;
}

class GetDriverForTripUseCase extends UseCase<DriverEntity?, GetDriverForTripParams> {
  GetDriverForTripUseCase(this._repository);

  final DriverRepository _repository;

  @override
  Future<Either<Failure, DriverEntity?>> call(
    GetDriverForTripParams params,
  ) async {
    final name = params.driverName;
    if (name == null || name.isEmpty) {
      return const Right(null);
    }
    try {
      final driver = await _repository.findByName(name);
      return Right(driver);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
