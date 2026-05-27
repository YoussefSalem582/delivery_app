part of 'map_bloc.dart';

abstract class RequestRideEvent extends Equatable {
  const RequestRideEvent();
  @override
  List<Object?> get props => [];
}

class RequestRideSubmitted extends RequestRideEvent {
  const RequestRideSubmitted({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
  });

  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;

  @override
  List<Object?> get props => [
        pickupAddress,
        dropoffAddress,
        pickupLat,
        pickupLng,
        dropoffLat,
        dropoffLng,
      ];
}

abstract class RequestRideState extends Equatable {
  const RequestRideState();
  @override
  List<Object?> get props => [];
}

class RequestRideInitial extends RequestRideState {
  const RequestRideInitial();
}

class RequestRideLoading extends RequestRideState {
  const RequestRideLoading();
}

class RequestRideSuccess extends RequestRideState {
  const RequestRideSuccess(this.trip);
  final TripEntity trip;
  @override
  List<Object?> get props => [trip];
}

class RequestRideError extends RequestRideState {
  const RequestRideError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class MapStarted extends MapEvent {
  const MapStarted();
}

class MapPositionUpdated extends MapEvent {
  const MapPositionUpdated(this.position);
  final LatLng position;
  @override
  List<Object?> get props => [position];
}

class MapStopped extends MapEvent {
  const MapStopped();
}

abstract class MapState extends Equatable {
  const MapState();
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapReady extends MapState {
  const MapReady({
    required this.userPosition,
    this.usingFallback = false,
  });

  final LatLng userPosition;
  final bool usingFallback;

  MapReady copyWith({LatLng? userPosition, bool? usingFallback}) {
    return MapReady(
      userPosition: userPosition ?? this.userPosition,
      usingFallback: usingFallback ?? this.usingFallback,
    );
  }

  @override
  List<Object?> get props => [userPosition, usingFallback];
}

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();
  @override
  List<Object?> get props => [];
}

class TrackingStarted extends TrackingEvent {
  const TrackingStarted(this.trip);
  final TripEntity trip;
  @override
  List<Object?> get props => [trip];
}

class TrackingTick extends TrackingEvent {
  const TrackingTick(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class TrackingStopped extends TrackingEvent {
  const TrackingStopped();
}

abstract class TrackingState extends Equatable {
  const TrackingState();
  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingLoading extends TrackingState {
  const TrackingLoading({required this.trip});

  final TripEntity trip;

  @override
  List<Object?> get props => [trip];
}

class TrackingActive extends TrackingState {
  const TrackingActive({
    required this.trip,
    required this.route,
    required this.driverPosition,
    required this.progress,
    required this.etaMinutes,
  });

  final TripEntity trip;
  final List<LatLng> route;
  final LatLng driverPosition;
  final double progress;
  final int etaMinutes;

  TrackingActive copyWith({
    TripEntity? trip,
    List<LatLng>? route,
    LatLng? driverPosition,
    double? progress,
    int? etaMinutes,
  }) {
    return TrackingActive(
      trip: trip ?? this.trip,
      route: route ?? this.route,
      driverPosition: driverPosition ?? this.driverPosition,
      progress: progress ?? this.progress,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }

  @override
  List<Object?> get props =>
      [trip, route, driverPosition, progress, etaMinutes];
}
