import 'package:dartz/dartz.dart';
import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';
import 'package:delivery_app/features/driver/shared/domain/repositories/driver_profile_repository.dart';

class RegisterDriverParams {
  const RegisterDriverParams({
    required this.phone,
    required this.vehicleType,
    required this.vehicleMakeModel,
    required this.licensePlate,
    required this.termsAccepted,
  });

  final String phone;
  final String vehicleType;
  final String vehicleMakeModel;
  final String licensePlate;
  final bool termsAccepted;
}

class RegisterDriverUseCase
    extends UseCase<DriverProfileEntity, RegisterDriverParams> {
  RegisterDriverUseCase(this._repository);

  final DriverProfileRepository _repository;

  @override
  Future<Either<Failure, DriverProfileEntity>> call(
    RegisterDriverParams params,
  ) async {
    try {
      final profile = await _repository.registerDriver(
        phone: params.phone,
        vehicleType: params.vehicleType,
        vehicleMakeModel: params.vehicleMakeModel,
        licensePlate: params.licensePlate,
        termsAccepted: params.termsAccepted,
      );
      return Right(profile);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class GetDriverProfileUseCase extends UseCase<DriverProfileEntity?, NoParams> {
  GetDriverProfileUseCase(this._repository);

  final DriverProfileRepository _repository;

  @override
  Future<Either<Failure, DriverProfileEntity?>> call(NoParams params) async {
    try {
      return Right(await _repository.getDriverProfile());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
