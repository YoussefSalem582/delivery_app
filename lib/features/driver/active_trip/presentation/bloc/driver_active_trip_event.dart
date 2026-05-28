part of 'driver_active_trip_bloc.dart';

abstract class DriverActiveTripEvent extends Equatable {
  const DriverActiveTripEvent();

  @override
  List<Object?> get props => [];
}

class DriverActiveTripLoadRequested extends DriverActiveTripEvent {
  const DriverActiveTripLoadRequested({required this.tripId});

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class DriverActiveTripArrivedRequested extends DriverActiveTripEvent {
  const DriverActiveTripArrivedRequested({required this.tripId});

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class DriverActiveTripStartRequested extends DriverActiveTripEvent {
  const DriverActiveTripStartRequested({required this.tripId});

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class DriverActiveTripCompleteRequested extends DriverActiveTripEvent {
  const DriverActiveTripCompleteRequested({required this.tripId});

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class DriverActiveTripLocationUpdateRequested extends DriverActiveTripEvent {
  const DriverActiveTripLocationUpdateRequested({
    required this.tripId,
    required this.lat,
    required this.lng,
  });

  final String tripId;
  final double lat;
  final double lng;

  @override
  List<Object?> get props => [tripId, lat, lng];
}
