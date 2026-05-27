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
