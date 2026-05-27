import 'dart:async';

import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/core/utils/constants.dart';
import 'package:delivery_app/core/utils/route_geometry.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

part 'map_event.dart';

class RequestRideBloc extends Bloc<RequestRideEvent, RequestRideState> {
  RequestRideBloc({required this._repository, required this._fcmService})
    : super(const RequestRideInitial()) {
    on<RequestRideSubmitted>(_onSubmit);
  }

  final TripRepository _repository;
  final FcmService _fcmService;

  Future<void> _onSubmit(
    RequestRideSubmitted event,
    Emitter<RequestRideState> emit,
  ) async {
    emit(const RequestRideLoading());
    try {
      final trip = await _repository.requestTrip(
        pickupAddress: event.pickupAddress,
        dropoffAddress: event.dropoffAddress,
        pickupLat: event.pickupLat,
        pickupLng: event.pickupLng,
        dropoffLat: event.dropoffLat,
        dropoffLng: event.dropoffLng,
      );
      await _fcmService.simulateTripNotification(
        title: 'notification_trip_update',
        body: 'notification_trip_accepted',
        tripId: trip.id,
      );
      emit(RequestRideSuccess(trip));
    } catch (e) {
      emit(RequestRideError(e.toString()));
    }
  }
}

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(const MapInitial()) {
    on<MapStarted>(_onStarted);
    on<MapPositionUpdated>(_onPositionUpdated);
    on<MapStopped>(_onStopped);
  }

  StreamSubscription<Position>? _positionSub;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(const MapLoading());
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        emit(
          MapReady(
            userPosition: const LatLng(
              AppConstants.defaultPickupLat,
              AppConstants.defaultPickupLng,
            ),
            usingFallback: true,
          ),
        );
        return;
      }
    }

    _positionSub?.cancel();
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          add(
            MapPositionUpdated(LatLng(position.latitude, position.longitude)),
          );
        });

    try {
      final position = await Geolocator.getCurrentPosition();
      emit(
        MapReady(userPosition: LatLng(position.latitude, position.longitude)),
      );
    } catch (_) {
      emit(
        const MapReady(
          userPosition: LatLng(
            AppConstants.defaultPickupLat,
            AppConstants.defaultPickupLng,
          ),
          usingFallback: true,
        ),
      );
    }
  }

  void _onPositionUpdated(MapPositionUpdated event, Emitter<MapState> emit) {
    if (state is MapReady) {
      emit((state as MapReady).copyWith(userPosition: event.position));
    }
  }

  Future<void> _onStopped(MapStopped event, Emitter<MapState> emit) async {
    await _positionSub?.cancel();
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc(this._routeService) : super(const TrackingInitial()) {
    on<TrackingStarted>(_onStarted);
    on<TrackingTick>(_onTick);
    on<TrackingStopped>(_onStopped);
  }

  final RouteService _routeService;
  Timer? _timer;
  List<LatLng> _route = [];
  DateTime? _startedAt;
  double _durationSeconds = 600;
  int _initialEtaMinutes = 12;

  Future<void> _onStarted(
    TrackingStarted event,
    Emitter<TrackingState> emit,
  ) async {
    emit(TrackingLoading(trip: event.trip));

    final pickup = LatLng(event.trip.pickupLat, event.trip.pickupLng);
    final dropoff = LatLng(event.trip.dropoffLat, event.trip.dropoffLng);
    final routeResult = await _routeService.getRoute(
      pickup: pickup,
      dropoff: dropoff,
    );

    _route = routeResult.points;
    _initialEtaMinutes = routeResult.etaMinutes;
    _durationSeconds = routeResult.durationSeconds;
    _startedAt = DateTime.now();

    final split = splitRouteAtProgress(_route, 0);

    emit(
      TrackingActive(
        trip: event.trip,
        route: _route,
        driverPosition: _route.first,
        driverBearing: bearingAtProgress(_route, 0),
        traveledRoute: split.traveled,
        remainingRoute: split.remaining,
        progress: 0,
        etaMinutes: _initialEtaMinutes,
      ),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      add(TrackingTick(DateTime.now()));
    });
  }

  void _onTick(TrackingTick event, Emitter<TrackingState> emit) {
    if (state is! TrackingActive || _startedAt == null || _route.length < 2) {
      return;
    }

    final current = state as TrackingActive;
    final elapsedSeconds =
        event.now.difference(_startedAt!).inMilliseconds / 1000;
    final progress =
        (elapsedSeconds / _durationSeconds).clamp(0.0, 1.0).toDouble();
    final split = splitRouteAtProgress(_route, progress);

    emit(
      current.copyWith(
        driverPosition: interpolateAlongRoute(_route, progress),
        driverBearing: bearingAtProgress(_route, progress),
        traveledRoute: split.traveled,
        remainingRoute: split.remaining,
        progress: progress,
        etaMinutes: ((1 - progress) * _initialEtaMinutes).ceil().clamp(1, 99),
      ),
    );

    if (progress >= 1.0) {
      _timer?.cancel();
    }
  }

  Future<void> _onStopped(
    TrackingStopped event,
    Emitter<TrackingState> emit,
  ) async {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
