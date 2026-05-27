import 'package:dartz/dartz.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetTripsUseCase extends UseCase<List<TripEntity>, NoParams> {
  GetTripsUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, List<TripEntity>>> call(NoParams params) async {
    try {
      final trips = await _repository.getTrips();
      return Right(trips);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class RefreshTripsUseCase extends UseCase<List<TripEntity>, NoParams> {
  RefreshTripsUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, List<TripEntity>>> call(NoParams params) async {
    try {
      final trips = await _repository.getTrips(forceRefresh: true);
      return Right(trips);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class GetCachedTripsUseCase extends UseCase<List<TripEntity>, NoParams> {
  GetCachedTripsUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, List<TripEntity>>> call(NoParams params) async {
    return Right(_repository.getCachedTrips());
  }
}

class GetTripDetailParams {
  const GetTripDetailParams(this.tripId);

  final String tripId;
}

class GetTripDetailUseCase extends UseCase<TripEntity, GetTripDetailParams> {
  GetTripDetailUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, TripEntity>> call(GetTripDetailParams params) async {
    try {
      final trip = await _repository.getTripById(params.tripId);
      if (trip == null) {
        return const Left(NotFoundFailure(message: 'Trip not found'));
      }
      return Right(trip);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class GetCachedTripDetailParams {
  const GetCachedTripDetailParams(this.tripId);

  final String tripId;
}

class GetCachedTripDetailUseCase
    extends UseCase<TripEntity?, GetCachedTripDetailParams> {
  GetCachedTripDetailUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, TripEntity?>> call(
    GetCachedTripDetailParams params,
  ) async {
    final matches =
        _repository.getCachedTrips().where((t) => t.id == params.tripId);
    return Right(matches.isEmpty ? null : matches.first);
  }
}

class UpdateTripStatusParams {
  const UpdateTripStatusParams({required this.tripId, required this.status});

  final String tripId;
  final TripStatus status;
}

class UpdateTripStatusUseCase
    extends UseCase<TripEntity, UpdateTripStatusParams> {
  UpdateTripStatusUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, TripEntity>> call(UpdateTripStatusParams params) async {
    try {
      final trip = await _repository.updateTripStatus(
        params.tripId,
        params.status,
      );
      return Right(trip);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class RequestTripParams {
  const RequestTripParams({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.fare,
    this.distanceKm,
    this.etaMinutes,
    this.paymentMethodKey,
    this.rideTierKey,
  });

  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double fare;
  final double? distanceKm;
  final int? etaMinutes;
  final String? paymentMethodKey;
  final String? rideTierKey;
}

class RequestTripUseCase extends UseCase<TripEntity, RequestTripParams> {
  RequestTripUseCase(this._repository);

  final TripRepository _repository;

  @override
  Future<Either<Failure, TripEntity>> call(RequestTripParams params) async {
    try {
      final trip = await _repository.requestTrip(
        pickupAddress: params.pickupAddress,
        dropoffAddress: params.dropoffAddress,
        pickupLat: params.pickupLat,
        pickupLng: params.pickupLng,
        dropoffLat: params.dropoffLat,
        dropoffLng: params.dropoffLng,
        fare: params.fare,
        distanceKm: params.distanceKm,
        etaMinutes: params.etaMinutes,
        paymentMethodKey: params.paymentMethodKey,
        rideTierKey: params.rideTierKey,
      );
      return Right(trip);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
