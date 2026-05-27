import 'dart:async';

import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/core/utils/route_geometry.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_payment.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_driver_for_trip_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc({
    required RouteService routeService,
    required GetTripDetailUseCase getTripDetail,
    required GetDriverForTripUseCase getDriverForTrip,
    required UpdateTripStatusUseCase updateTripStatus,
    required AuthRepository authRepository,
    required FcmService fcmService,
    VoidCallback? onTripsChanged,
  })  : _routeService = routeService,
        _getTripDetail = getTripDetail,
        _getDriverForTrip = getDriverForTrip,
        _updateTripStatus = updateTripStatus,
        _authRepository = authRepository,
        _fcmService = fcmService,
        _onTripsChanged = onTripsChanged,
        super(const TrackingInitial()) {
    on<TrackingLoadRequested>(_onLoadRequested);
    on<TrackingTick>(_onTick);
    on<TrackingStatusPollRequested>(_onStatusPoll);
    on<TrackingStopped>(_onStopped);
  }

  final RouteService _routeService;
  final GetTripDetailUseCase _getTripDetail;
  final GetDriverForTripUseCase _getDriverForTrip;
  final UpdateTripStatusUseCase _updateTripStatus;
  final AuthRepository _authRepository;
  final FcmService _fcmService;
  final VoidCallback? _onTripsChanged;

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

    final activeTrip = await _ensureInProgress(trip, notify: false);

    DriverEntity? driver;
    final driverResult = await _getDriverForTrip(
      GetDriverForTripParams(driverName: activeTrip.driverName),
    );
    driverResult.fold((_) {}, (value) => driver = value);

    final pickup = LatLng(activeTrip.pickupLat, activeTrip.pickupLng);
    final dropoff = LatLng(activeTrip.dropoffLat, activeTrip.dropoffLng);

    try {
      final routeResult = await _routeService.getRoute(
        pickup: pickup,
        dropoff: dropoff,
      );

      _route = routeResult.points;
      _initialEtaMinutes = activeTrip.etaMinutes ?? routeResult.etaMinutes;
      _durationSeconds = activeTrip.etaMinutes != null
          ? activeTrip.etaMinutes! * 60
          : routeResult.durationSeconds;
      _startedAt = DateTime.now();

      final driverPosition = driver != null
          ? LatLng(driver!.lat, driver!.lng)
          : pickup;

      final split = splitRouteAtProgress(_route, 0);
      final driverRating = driver?.rating ?? activeTrip.driverRating;
      final driverVehicle = driver?.vehicle ?? activeTrip.driverVehicle;
      final driverPhone = driver?.phone ?? activeTrip.driverPhone;

      emit(
        TrackingActive(
          trip: activeTrip,
          route: _route,
          driverPosition: driverPosition,
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
      _onTripsChanged?.call();
    } catch (_) {
      emit(const TrackingError('error_generic'));
    }
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
      unawaited(_completeTrip(current.trip));
      emit(
        TrackingCompleted(
          trip: current.trip.copyWith(status: TripStatus.completed),
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

  Future<TripEntity> _ensureInProgress(
    TripEntity trip, {
    bool notify = true,
  }) async {
    if (trip.status == TripStatus.inProgress ||
        trip.status == TripStatus.completed ||
        trip.status == TripStatus.cancelled) {
      return trip;
    }

    final result = await _updateTripStatus(
      UpdateTripStatusParams(tripId: trip.id, status: TripStatus.inProgress),
    );
    return result.fold(
      (_) => trip,
      (updated) {
        if (notify) {
          _onTripsChanged?.call();
        }
        return updated;
      },
    );
  }

  Future<void> _completeTrip(TripEntity trip) async {
    if (trip.status == TripStatus.completed) {
      _onTripsChanged?.call();
      return;
    }

    final result = await _updateTripStatus(
      UpdateTripStatusParams(
        tripId: trip.id,
        status: TripStatus.completed,
      ),
    );
    await result.fold(
      (_) async {},
      (completed) async {
        if (tripUsesWallet(completed.paymentMethodKey)) {
          await _authRepository.updateWalletBalance(-trip.fare);
        }
        await _fcmService.simulateTripNotification(
          title: 'notification_trip_update',
          body: 'status_completed',
          tripId: completed.id,
        );
        _onTripsChanged?.call();
      },
    );
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
