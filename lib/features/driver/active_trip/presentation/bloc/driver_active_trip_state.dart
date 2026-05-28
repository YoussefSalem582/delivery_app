part of 'driver_active_trip_bloc.dart';

class DriverActiveTripState extends Equatable {
  const DriverActiveTripState();

  @override
  List<Object?> get props => [];
}

class DriverActiveTripInitial extends DriverActiveTripState {
  const DriverActiveTripInitial();
}

class DriverActiveTripLoading extends DriverActiveTripState {
  const DriverActiveTripLoading({required this.tripId});

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class DriverActiveTripLoaded extends DriverActiveTripState {
  const DriverActiveTripLoaded({required this.trip, this.isUpdating = false});

  final TripEntity trip;
  final bool isUpdating;

  bool get canMarkArrived => trip.status == TripStatus.accepted;

  bool get canStartTrip => trip.status == TripStatus.driverArrived;

  bool get canCompleteTrip => trip.status == TripStatus.inProgress;

  DriverActiveTripLoaded copyWith({TripEntity? trip, bool? isUpdating}) {
    return DriverActiveTripLoaded(
      trip: trip ?? this.trip,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [trip, isUpdating];
}

class DriverActiveTripError extends DriverActiveTripState {
  const DriverActiveTripError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
