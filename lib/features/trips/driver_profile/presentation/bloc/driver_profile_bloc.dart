import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_review_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_driver_for_trip_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_driver_reviews_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_profile_event.dart';
part 'driver_profile_state.dart';

class DriverProfileData extends Equatable {
  const DriverProfileData({
    required this.tripId,
    required this.name,
    this.driverId,
    this.phone,
    this.avatarUrl,
    this.rating,
    this.vehicle,
    this.reviews = const [],
    this.ratingSummary,
  });

  final String tripId;
  final String name;
  final String? driverId;
  final String? phone;
  final String? avatarUrl;
  final double? rating;
  final String? vehicle;
  final List<DriverReviewEntity> reviews;
  final DriverRatingSummary? ratingSummary;

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  @override
  List<Object?> get props => [
        tripId,
        name,
        driverId,
        phone,
        avatarUrl,
        rating,
        vehicle,
        reviews,
        ratingSummary,
      ];
}

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  DriverProfileBloc({
    required GetTripDetailUseCase getTripDetail,
    required GetDriverForTripUseCase getDriverForTrip,
    required GetDriverReviewsUseCase getDriverReviews,
  })  : _getTripDetail = getTripDetail,
        _getDriverForTrip = getDriverForTrip,
        _getDriverReviews = getDriverReviews,
        super(const DriverProfileInitial()) {
    on<DriverProfileLoadRequested>(_onLoad);
  }

  final GetTripDetailUseCase _getTripDetail;
  final GetDriverForTripUseCase _getDriverForTrip;
  final GetDriverReviewsUseCase _getDriverReviews;

  Future<void> _onLoad(
    DriverProfileLoadRequested event,
    Emitter<DriverProfileState> emit,
  ) async {
    emit(const DriverProfileLoading());

    final tripResult = await _getTripDetail(GetTripDetailParams(event.tripId));
    await tripResult.fold(
      (Failure failure) async => emit(DriverProfileError(failure.message)),
      (TripEntity trip) async {
        final name = trip.driverName;
        if (name == null || name.isEmpty) {
          emit(const DriverProfileError('call_no_driver'));
          return;
        }

        DriverEntity? driver;
        final driverResult = await _getDriverForTrip(
          GetDriverForTripParams(driverName: name),
        );
        driverResult.fold((_) {}, (value) => driver = value);

        var reviews = <DriverReviewEntity>[];
        final driverId = driver?.id;
        if (driverId != null && driverId.isNotEmpty) {
          final reviewsResult = await _getDriverReviews(
            GetDriverReviewsParams(driverId: driverId),
          );
          reviewsResult.fold((_) {}, (value) => reviews = value);
        }

        final ratingSummary = reviews.isNotEmpty
            ? DriverRatingSummary.fromReviews(reviews)
            : null;

        emit(
          DriverProfileLoaded(
            profile: DriverProfileData(
              tripId: trip.id,
              name: name,
              driverId: driverId,
              phone: trip.driverPhone ?? driver?.phone,
              avatarUrl: trip.driverAvatarUrl,
              rating: ratingSummary?.averageRating ??
                  trip.driverRating ??
                  driver?.rating,
              vehicle: trip.driverVehicle ?? driver?.vehicle,
              reviews: reviews,
              ratingSummary: ratingSummary,
            ),
          ),
        );
      },
    );
  }
}
