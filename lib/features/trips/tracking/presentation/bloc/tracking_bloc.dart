import 'dart:async';

import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/core/utils/route_geometry.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_driver_for_trip_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc({
    required RouteService routeService,
    required GetTripDetailUseCase getTripDetail,
    required GetDriverForTripUseCase getDriverForTrip,
  })  : _routeService = routeService,
        _getTripDetail = getTripDetail,
        _getDriverForTrip = getDriverForTrip,
        super(const TrackingInitial()) {
    on<TrackingLoadRequested>(_onLoadRequested);
    on<TrackingTick>(_onTick);
    on<TrackingStatusPollRequested>(_onStatusPoll);
    on<TrackingStopped>(_onStopped);
  }

  final RouteService _routeService;
  final GetTripDetailUseCase _getTripDetail;
  final GetDriverForTripUseCase _getDriverForTrip;

  Timer? _animationTimer;
  Timer? _statusPollTimer;
  List<LatLng> _route = [];
  DateTime? _startedAt;
  double _durationSeconds = 600;
  int _initialEtaMinutes = 12;
  String? _tripId;

  Future<void> _onLoadRequested(
    TrackingLoadRequested event,
    Emitter<TrackingState> emit,
  ) async {
    _tripId = event.tripId;
    emit(TrackingLoading(tripId: event.tripId));

    final tripResult = await _getTripDetail(GetTripDetailParams(event.tripId));
    final trip = tripResult.fold<TripEntity?>(
      (failure) {
        emit(TrackingError(failure.message));
        return null;
      },
      (value) => value,
    );
    if (trip == null) return;

    if (trip.status == TripStatus.completed) {
      emit(TrackingError('tracking_already_completed'));
      return;
    }
    if (trip.status == TripStatus.cancelled) {
      emit(TrackingError('tracking_trip_cancelled'));
      return;
    }

    DriverEntity? driver;
    final driverResult = await _getDriverForTrip(
      GetDriverForTripParams(driverName: trip.driverName),
    );
    driverResult.fold((_) {}, (value) => driver = value);

    final routeOrigin = _routeOrigin(trip, driver);
    final dropoff = LatLng(trip.dropoffLat, trip.dropoffLng);

    try {
      final routeResult = await _routeService.getRoute(
        pickup: routeOrigin,
        dropoff: dropoff,
      );

      _route = routeResult.points;
      _initialEtaMinutes = routeResult.etaMinutes;
      _durationSeconds = routeResult.durationSeconds;
      _startedAt = DateTime.now();

      final split = splitRouteAtProgress(_route, 0);
      final driverRating = driver?.rating ?? trip.driverRating;
      final driverVehicle = driver?.vehicle ?? trip.driverVehicle;
      final driverPhone = driver?.phone ?? trip.driverPhone;

      emit(
        TrackingActive(
          trip: trip,
          route: _route,
          driverPosition: _route.first,
          driverBearing: bearingAtProgress(_route, 0),
          traveledRoute: split.traveled,
          remainingRoute: split.remaining,
          progress: 0,
          etaMinutes: _initialEtaMinutes,
          driverRating: driverRating,
          driverVehicle: driverVehicle,
          driverPhone: driverPhone,
        ),
      );

      _startTimers();
    } catch (_) {
      emit(const TrackingError('error_generic'));
    }
  }

  LatLng _routeOrigin(TripEntity trip, DriverEntity? driver) {
    if (trip.status == TripStatus.requested) {
      return LatLng(trip.pickupLat, trip.pickupLng);
    }
    if (driver != null) {
      return LatLng(driver.lat, driver.lng);
    }
    return LatLng(trip.pickupLat, trip.pickupLng);
  }

  void _startTimers() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      add(TrackingTick(DateTime.now()));
    });

    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => add(const TrackingStatusPollRequested()),
    );
  }

  void _cancelTimers() {
    _animationTimer?.cancel();
    _statusPollTimer?.cancel();
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

    if (progress >= 1.0) {
      _cancelTimers();
      emit(
        TrackingCompleted(
          trip: current.trip,
          route: current.route,
          driverPosition: interpolateAlongRoute(_route, 1.0),
          driverBearing: bearingAtProgress(_route, 1.0),
          traveledRoute: split.traveled,
          remainingRoute: split.remaining,
          driverRating: current.driverRating,
          driverVehicle: current.driverVehicle,
          driverPhone: current.driverPhone,
        ),
      );
      return;
    }

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
  }

  Future<void> _onStatusPoll(
    TrackingStatusPollRequested event,
    Emitter<TrackingState> emit,
  ) async {
    final tripId = _tripId;
    if (tripId == null || state is! TrackingActive) return;

    final result = await _getTripDetail(GetTripDetailParams(tripId));
    result.fold((_) {}, (updatedTrip) {
      if (state is! TrackingActive) return;
      final current = state as TrackingActive;

      if (updatedTrip.status == TripStatus.cancelled) {
        _cancelTimers();
        emit(const TrackingError('tracking_trip_cancelled'));
        return;
      }

      if (updatedTrip.status == TripStatus.completed) {
        _cancelTimers();
        emit(
          TrackingCompleted(
            trip: updatedTrip,
            route: current.route,
            driverPosition: current.driverPosition,
            driverBearing: current.driverBearing,
            traveledRoute: current.traveledRoute,
            remainingRoute: current.remainingRoute,
            driverRating: current.driverRating,
            driverVehicle: current.driverVehicle,
            driverPhone: current.driverPhone,
          ),
        );
        return;
      }

      emit(current.copyWith(trip: updatedTrip));
    });
  }

  Future<void> _onStopped(
    TrackingStopped event,
    Emitter<TrackingState> emit,
  ) async {
    _cancelTimers();
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
