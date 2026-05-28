import 'dart:async';

import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';
import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/core/utils/route_geometry.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/driver/shared/domain/repositories/driver_trip_repository.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_payment.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_driver_for_trip_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_rider_for_trip_usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

enum TrackingRole { rider, driver }

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc({
    required RouteService routeService,
    required GetTripDetailUseCase getTripDetail,
    required GetDriverForTripUseCase getDriverForTrip,
    required GetRiderForTripUseCase getRiderForTrip,
    required UpdateTripStatusUseCase updateTripStatus,
    required DriverTripRepository driverTripRepository,
    required AuthRepository authRepository,
    required FcmService fcmService,
    VoidCallback? onTripsChanged,
  })  : _routeService = routeService,
        _getTripDetail = getTripDetail,
        _getDriverForTrip = getDriverForTrip,
        _getRiderForTrip = getRiderForTrip,
        _updateTripStatus = updateTripStatus,
        _driverTripRepository = driverTripRepository,
        _authRepository = authRepository,
        _fcmService = fcmService,
        _onTripsChanged = onTripsChanged,
        super(const TrackingInitial()) {
    on<TrackingLoadRequested>(_onLoadRequested);
    on<TrackingTick>(_onTick);
    on<TrackingStatusPollRequested>(_onStatusPoll);
    on<TrackingDriverStatusRequested>(_onDriverStatusRequested);
    on<TrackingStopped>(_onStopped);
  }

  final RouteService _routeService;
  final GetTripDetailUseCase _getTripDetail;
  final GetDriverForTripUseCase _getDriverForTrip;
  final GetRiderForTripUseCase _getRiderForTrip;
  final UpdateTripStatusUseCase _updateTripStatus;
  final DriverTripRepository _driverTripRepository;
  final AuthRepository _authRepository;
  final FcmService _fcmService;
  final VoidCallback? _onTripsChanged;

  Timer? _animationTimer;
  Timer? _statusPollTimer;
  List<LatLng> _route = [];
  DateTime? _lastTickAt;
  double _distanceTraveledMeters = 0;
  double _totalDistanceMeters = 1;
  double _avgSpeedMps = 8.33;
  double _phaseBoundaryProgress = 0.5;
  bool _driverArrivedNotified = false;
  TrackingRole _role = TrackingRole.rider;
  String? _tripId;

  Future<void> _onLoadRequested(
    TrackingLoadRequested event,
    Emitter<TrackingState> emit,
  ) async {
    _tripId = event.tripId;
    _role = event.role;
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

    final activeTrip = _role == TrackingRole.driver ||
            trip.status == TripStatus.requested ||
            trip.status == TripStatus.accepted
        ? trip
        : await _ensureInProgress(trip, notify: false);

    DriverEntity? driver;
    final driverResult = await _getDriverForTrip(
      GetDriverForTripParams(
        driverId: activeTrip.driverId,
        driverName: activeTrip.driverName,
      ),
    );
    driverResult.fold((_) {}, (value) => driver = value);

    double? riderRating;
    String? riderName;
    String? riderPhone;
    String? riderAvatarUrl;
    if (_role == TrackingRole.driver) {
      final riderResult = await _getRiderForTrip(
        GetRiderForTripParams(riderId: activeTrip.riderId),
      );
      riderResult.fold((_) {}, (rider) {
        if (rider != null) {
          riderName = rider.name;
          riderPhone = rider.phone;
          riderAvatarUrl = rider.avatarUrl;
          riderRating = rider.rating;
        }
      });
    }

    final pickup = LatLng(activeTrip.pickupLat, activeTrip.pickupLng);
    final dropoff = LatLng(activeTrip.dropoffLat, activeTrip.dropoffLng);

    try {
      final routePlan = await _routeService.getTripRoutePlan(
        pickup: pickup,
        dropoff: dropoff,
        placementSeed: activeTrip.id,
      );

      _route = routePlan.fullRoute;
      _totalDistanceMeters = routePlan.totalDistanceMeters;
      _avgSpeedMps = routePlan.avgSpeedMps;
      _phaseBoundaryProgress = routePlan.phaseBoundaryProgress;
      _driverArrivedNotified =
          activeTrip.status == TripStatus.driverArrived ||
          activeTrip.status == TripStatus.inProgress;

      final approachStart = routePlan.approachLeg.points.first;
      final projection = projectPointOntoRoute(
        routePlan.approachLeg.points,
        approachStart,
      );
      _distanceTraveledMeters = _resolveInitialDistanceTraveled(
        trip: activeTrip,
        projectedDistanceOnApproach: projection.distanceAlongRoute,
        approachDistanceMeters: routePlan.approachLeg.distanceMeters,
        totalDistanceMeters: routePlan.totalDistanceMeters,
        route: _route,
      );

      final progress = (_distanceTraveledMeters / _totalDistanceMeters)
          .clamp(0.0, 1.0)
          .toDouble();
      final split = splitRouteAtProgress(_route, progress);
      final phase = _phaseForProgress(progress);
      final remainingMeters = remainingDistanceMeters(_route, progress);
      final etaMinutes =
          _etaMinutesFromRemainingMeters(remainingMeters, _avgSpeedMps);

      final driverRating = driver?.rating ?? activeTrip.driverRating;
      final driverVehicle = driver?.vehicle ?? activeTrip.driverVehicle;
      final driverPhone = driver?.phone ?? activeTrip.driverPhone;

      emit(
        TrackingActive(
          trip: activeTrip,
          route: _route,
          driverPosition: interpolateAlongRoute(_route, progress),
          driverBearing: bearingAtProgress(_route, progress),
          traveledRoute: split.traveled,
          remainingRoute: split.remaining,
          progress: progress,
          etaMinutes: etaMinutes,
          phase: phase,
          remainingDistanceKm: remainingMeters / 1000,
          driverRating: driverRating,
          driverVehicle: driverVehicle,
          driverPhone: driverPhone,
          role: _role,
          riderName: riderName,
          riderPhone: riderPhone,
          riderAvatarUrl: riderAvatarUrl,
          riderRating: riderRating,
        ),
      );

      _lastTickAt = DateTime.now();
      if (_role == TrackingRole.driver) {
        _startAnimationTimer();
      } else if (activeTrip.driverId == null &&
          activeTrip.status != TripStatus.requested &&
          activeTrip.status != TripStatus.accepted) {
        _startTimers();
      } else {
        _startStatusPollTimer();
      }
      _onTripsChanged?.call();
    } catch (_) {
      emit(const TrackingError('error_generic'));
    }
  }

  double _resolveInitialDistanceTraveled({
    required TripEntity trip,
    required double projectedDistanceOnApproach,
    required double approachDistanceMeters,
    required double totalDistanceMeters,
    required List<LatLng> route,
  }) {
    var initial = projectedDistanceOnApproach;

    if (_role == TrackingRole.driver &&
        trip.driverLat != null &&
        trip.driverLng != null &&
        route.length >= 2) {
      final projection = projectPointOntoRoute(
        route,
        LatLng(trip.driverLat!, trip.driverLng!),
      );
      initial = projection.distanceAlongRoute;
    } else if (trip.status == TripStatus.driverArrived) {
      initial = approachDistanceMeters;
    } else if (trip.status == TripStatus.inProgress) {
      final elapsedSeconds =
          DateTime.now().difference(trip.updatedAt).inSeconds.toDouble();
      if (elapsedSeconds > 10) {
        initial = approachDistanceMeters + (elapsedSeconds * _avgSpeedMps);
      }
    }

    return initial.clamp(0, totalDistanceMeters);
  }

  void _startAnimationTimer() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      add(TrackingTick(DateTime.now()));
    });
  }

  void _startStatusPollTimer() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => add(const TrackingStatusPollRequested()),
    );
  }

  void _startTimers() {
    _startAnimationTimer();
    _startStatusPollTimer();
  }

  void _cancelTimers() {
    _animationTimer?.cancel();
    _statusPollTimer?.cancel();
  }

  Future<void> _onTick(TrackingTick event, Emitter<TrackingState> emit) async {
    if (state is! TrackingActive || _route.length < 2) {
      return;
    }

    final current = state as TrackingActive;
    if (current.role == TrackingRole.driver) {
      _onDriverTick(event, current, emit);
      return;
    }
    if (current.trip.driverId != null) {
      return;
    }
    final lastTick = _lastTickAt ?? event.now;
    final deltaSeconds =
        event.now.difference(lastTick).inMilliseconds / 1000;
    _lastTickAt = event.now;

    _distanceTraveledMeters = (_distanceTraveledMeters +
            (_avgSpeedMps * deltaSeconds))
        .clamp(0, _totalDistanceMeters);

    final progress = (_distanceTraveledMeters / _totalDistanceMeters)
        .clamp(0.0, 1.0)
        .toDouble();
    final split = splitRouteAtProgress(_route, progress);
    final remainingMeters = remainingDistanceMeters(_route, progress);
    final etaMinutes =
        _etaMinutesFromRemainingMeters(remainingMeters, _avgSpeedMps);
    final phase = _phaseForProgress(progress);

    if (phase == TrackingPhase.onTrip && !_driverArrivedNotified) {
      _driverArrivedNotified = true;
      unawaited(_markDriverArrived(current.trip));
    }

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
          riderName: current.riderName,
          riderPhone: current.riderPhone,
          riderAvatarUrl: current.riderAvatarUrl,
          riderRating: current.riderRating,
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
        etaMinutes: etaMinutes,
        phase: phase,
        remainingDistanceKm: remainingMeters / 1000,
      ),
    );
  }

  void _onDriverTick(
    TrackingTick event,
    TrackingActive current,
    Emitter<TrackingState> emit,
  ) {
    final lastTick = _lastTickAt ?? event.now;
    final deltaSeconds =
        event.now.difference(lastTick).inMilliseconds / 1000;
    _lastTickAt = event.now;

    _distanceTraveledMeters = (_distanceTraveledMeters +
            (_avgSpeedMps * deltaSeconds))
        .clamp(0, _totalDistanceMeters);

    final progress = (_distanceTraveledMeters / _totalDistanceMeters)
        .clamp(0.0, 1.0)
        .toDouble();
    final split = splitRouteAtProgress(_route, progress);
    final remainingMeters = remainingDistanceMeters(_route, progress);
    final etaMinutes =
        _etaMinutesFromRemainingMeters(remainingMeters, _avgSpeedMps);
    final phase = _phaseForProgress(progress);
    final driverPosition = interpolateAlongRoute(_route, progress);

    emit(
      current.copyWith(
        driverPosition: driverPosition,
        driverBearing: bearingAtProgress(_route, progress),
        traveledRoute: split.traveled,
        remainingRoute: split.remaining,
        progress: progress,
        etaMinutes: etaMinutes,
        phase: phase,
        remainingDistanceKm: remainingMeters / 1000,
      ),
    );

    unawaited(_publishDriverLocation(driverPosition));
  }

  Future<void> _publishDriverLocation(LatLng position) async {
    final tripId = _tripId;
    if (tripId == null) return;

    try {
      await _driverTripRepository.updateDriverLocation(
        tripId,
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (_) {}
  }

  Future<void> _onDriverStatusRequested(
    TrackingDriverStatusRequested event,
    Emitter<TrackingState> emit,
  ) async {
    if (state is! TrackingActive) return;

    final current = state as TrackingActive;
    emit(current.copyWith(isUpdating: true));

    try {
      final trip = await _driverTripRepository.updateDriverTripStatus(
        event.tripId,
        event.status,
      );

      if (event.status == TripStatus.inProgress) {
        _distanceTraveledMeters =
            _phaseBoundaryProgress * _totalDistanceMeters;
      }

      if (event.status == TripStatus.completed) {
        _cancelTimers();
        emit(
          TrackingCompleted(
            trip: trip,
            route: current.route,
            driverPosition: current.driverPosition,
            driverBearing: current.driverBearing,
            traveledRoute: current.traveledRoute,
            remainingRoute: current.remainingRoute,
            driverRating: current.driverRating,
            driverVehicle: current.driverVehicle,
            driverPhone: current.driverPhone,
            role: current.role,
            riderName: current.riderName,
            riderPhone: current.riderPhone,
            riderAvatarUrl: current.riderAvatarUrl,
            riderRating: current.riderRating,
          ),
        );
      } else {
        final progress = (_distanceTraveledMeters / _totalDistanceMeters)
            .clamp(0.0, 1.0)
            .toDouble();
        final split = splitRouteAtProgress(_route, progress);
        final remainingMeters = remainingDistanceMeters(_route, progress);

        emit(
          current.copyWith(
            trip: trip,
            isUpdating: false,
            driverPosition: interpolateAlongRoute(_route, progress),
            driverBearing: bearingAtProgress(_route, progress),
            traveledRoute: split.traveled,
            remainingRoute: split.remaining,
            progress: progress,
            etaMinutes: _etaMinutesFromRemainingMeters(
              remainingMeters,
              _avgSpeedMps,
            ),
            phase: _phaseForProgress(progress),
            remainingDistanceKm: remainingMeters / 1000,
          ),
        );
      }

      if (event.status == TripStatus.driverArrived) {
        await _fcmService.simulateTripNotification(
          title: 'notification_trip_update',
          body: 'notification_driver_arrived',
          tripId: event.tripId,
          type: NotificationType.driverArrived,
        );
      } else if (event.status == TripStatus.inProgress) {
        await _fcmService.simulateTripNotification(
          title: 'notification_driver_on_the_way',
          body: 'notification_trip_in_progress_body',
          tripId: event.tripId,
          type: NotificationType.driverOnTheWay,
        );
      } else if (event.status == TripStatus.completed) {
        await _fcmService.simulateTripNotification(
          title: 'notification_trip_completed_title',
          body: 'notification_thanks_riding',
          tripId: event.tripId,
          type: NotificationType.tripCompleted,
        );
        await _authRepository.getProfile(forceRefresh: true);
      }

      _onTripsChanged?.call();
    } catch (e) {
      emit(TrackingError(e.toString()));
    }
  }

  TrackingPhase _phaseForProgress(double progress) {
    return progress >= _phaseBoundaryProgress
        ? TrackingPhase.onTrip
        : TrackingPhase.approach;
  }

  int _etaMinutesFromRemainingMeters(double remainingMeters, double speedMps) {
    if (speedMps <= 0) return 1;
    return (remainingMeters / speedMps / 60).ceil().clamp(1, 99);
  }

  Future<void> _markDriverArrived(TripEntity trip) async {
    if (trip.status == TripStatus.driverArrived ||
        trip.status == TripStatus.inProgress ||
        trip.status == TripStatus.completed) {
      return;
    }

    await _updateTripStatus(
      UpdateTripStatusParams(
        tripId: trip.id,
        status: TripStatus.driverArrived,
      ),
    );
    _onTripsChanged?.call();
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
            role: current.role,
            riderName: current.riderName,
            riderPhone: current.riderPhone,
            riderAvatarUrl: current.riderAvatarUrl,
            riderRating: current.riderRating,
          ),
        );
        return;
      }

      emit(current.copyWith(trip: updatedTrip));

      if (updatedTrip.driverLat != null && updatedTrip.driverLng != null) {
        final driverPos = LatLng(
          updatedTrip.driverLat!,
          updatedTrip.driverLng!,
        );
        emit(
          current.copyWith(
            trip: updatedTrip,
            driverPosition: driverPos,
          ),
        );
      }
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
        trip.status == TripStatus.driverArrived ||
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
          type: NotificationType.tripCompleted,
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
