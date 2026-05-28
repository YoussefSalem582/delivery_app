part of 'tracking_bloc.dart';

enum TrackingPhase { approach, onTrip }

abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingLoading extends TrackingState {
  const TrackingLoading({this.tripId});

  final String? tripId;

  @override
  List<Object?> get props => [tripId];
}

class TrackingActive extends TrackingState {
  const TrackingActive({
    required this.trip,
    required this.route,
    required this.driverPosition,
    required this.driverBearing,
    required this.traveledRoute,
    required this.remainingRoute,
    required this.progress,
    required this.etaMinutes,
    required this.phase,
    required this.remainingDistanceKm,
    this.driverRating,
    this.driverVehicle,
    this.driverPhone,
  });

  final TripEntity trip;
  final List<LatLng> route;
  final LatLng driverPosition;
  final double driverBearing;
  final List<LatLng> traveledRoute;
  final List<LatLng> remainingRoute;
  final double progress;
  final int etaMinutes;
  final TrackingPhase phase;
  final double remainingDistanceKm;
  final double? driverRating;
  final String? driverVehicle;
  final String? driverPhone;

  TrackingActive copyWith({
    TripEntity? trip,
    List<LatLng>? route,
    LatLng? driverPosition,
    double? driverBearing,
    List<LatLng>? traveledRoute,
    List<LatLng>? remainingRoute,
    double? progress,
    int? etaMinutes,
    TrackingPhase? phase,
    double? remainingDistanceKm,
    double? driverRating,
    String? driverVehicle,
    String? driverPhone,
  }) {
    return TrackingActive(
      trip: trip ?? this.trip,
      route: route ?? this.route,
      driverPosition: driverPosition ?? this.driverPosition,
      driverBearing: driverBearing ?? this.driverBearing,
      traveledRoute: traveledRoute ?? this.traveledRoute,
      remainingRoute: remainingRoute ?? this.remainingRoute,
      progress: progress ?? this.progress,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      phase: phase ?? this.phase,
      remainingDistanceKm: remainingDistanceKm ?? this.remainingDistanceKm,
      driverRating: driverRating ?? this.driverRating,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      driverPhone: driverPhone ?? this.driverPhone,
    );
  }

  @override
  List<Object?> get props => [
        trip.id,
        trip.status,
        driverPosition,
        driverBearing,
        progress,
        etaMinutes,
        phase,
        remainingDistanceKm,
        driverRating,
        driverVehicle,
        driverPhone,
      ];

  @override
  String toString() =>
      'TrackingActive(tripId: ${trip.id}, status: ${trip.status.name}, '
      'phase: ${phase.name}, progress: ${(progress * 100).toStringAsFixed(0)}%, '
      'eta: $etaMinutes min, remaining: ${remainingDistanceKm.toStringAsFixed(1)} km)';
}

class TrackingCompleted extends TrackingState {
  const TrackingCompleted({
    required this.trip,
    required this.route,
    required this.driverPosition,
    required this.driverBearing,
    required this.traveledRoute,
    required this.remainingRoute,
    this.driverRating,
    this.driverVehicle,
    this.driverPhone,
  });

  final TripEntity trip;
  final List<LatLng> route;
  final LatLng driverPosition;
  final double driverBearing;
  final List<LatLng> traveledRoute;
  final List<LatLng> remainingRoute;
  final double? driverRating;
  final String? driverVehicle;
  final String? driverPhone;

  @override
  List<Object?> get props => [
        trip.id,
        trip.status,
        driverPosition,
        driverRating,
        driverVehicle,
        driverPhone,
      ];

  @override
  String toString() =>
      'TrackingCompleted(tripId: ${trip.id}, status: ${trip.status.name})';
}

class TrackingError extends TrackingState {
  const TrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
