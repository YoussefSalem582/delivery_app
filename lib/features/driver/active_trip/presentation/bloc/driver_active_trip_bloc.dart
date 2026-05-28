import 'package:delivery_app/core/network/fcm_service.dart';

import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';

import 'package:delivery_app/features/driver/shared/domain/repositories/driver_trip_repository.dart';

import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';

import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

import 'package:delivery_app/features/trips/shared/domain/repositories/trip_repository.dart';

import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_active_trip_event.dart';

part 'driver_active_trip_state.dart';

class DriverActiveTripBloc
    extends Bloc<DriverActiveTripEvent, DriverActiveTripState> {
  DriverActiveTripBloc({
    required DriverTripRepository driverTripRepository,

    required TripRepository tripRepository,

    required FcmService fcmService,

    required AuthRepository authRepository,
  }) : _driverTripRepository = driverTripRepository,

       _tripRepository = tripRepository,

       _fcmService = fcmService,

       _authRepository = authRepository,

       super(const DriverActiveTripInitial()) {
    on<DriverActiveTripLoadRequested>(_onLoad);

    on<DriverActiveTripArrivedRequested>(_onArrived);

    on<DriverActiveTripStartRequested>(_onStart);

    on<DriverActiveTripCompleteRequested>(_onComplete);

    on<DriverActiveTripLocationUpdateRequested>(_onLocationUpdate);
  }

  final DriverTripRepository _driverTripRepository;

  final TripRepository _tripRepository;

  final FcmService _fcmService;

  final AuthRepository _authRepository;

  Future<void> _onLoad(
    DriverActiveTripLoadRequested event,

    Emitter<DriverActiveTripState> emit,
  ) async {
    emit(DriverActiveTripLoading(tripId: event.tripId));

    TripEntity? cached;

    for (final trip in _tripRepository.getCachedTrips()) {
      if (trip.id == event.tripId) {
        cached = trip;

        break;
      }
    }

    if (cached != null) {
      emit(DriverActiveTripLoaded(trip: cached));
    }

    try {
      final trip = await _tripRepository.getTripById(event.tripId);

      if (trip != null) {
        emit(DriverActiveTripLoaded(trip: trip));
      } else if (cached == null) {
        emit(const DriverActiveTripError('driver_trip_not_found'));
      }
    } catch (e) {
      if (cached == null) {
        emit(DriverActiveTripError(e.toString()));
      }
    }
  }

  Future<void> _updateStatus(
    String tripId,

    TripStatus status,

    Emitter<DriverActiveTripState> emit,
  ) async {
    final current = state;

    if (current is! DriverActiveTripLoaded) return;

    emit(current.copyWith(isUpdating: true));

    try {
      final trip = await _driverTripRepository.updateDriverTripStatus(
        tripId,
        status,
      );

      emit(DriverActiveTripLoaded(trip: trip));

      if (status == TripStatus.driverArrived) {
        await _fcmService.simulateTripNotification(
          title: 'notification_trip_update',

          body: 'notification_driver_arrived',

          tripId: tripId,

          type: NotificationType.driverArrived,
        );
      } else if (status == TripStatus.inProgress) {
        await _fcmService.simulateTripNotification(
          title: 'notification_driver_on_the_way',

          body: 'notification_trip_in_progress_body',

          tripId: tripId,

          type: NotificationType.driverOnTheWay,
        );
      } else if (status == TripStatus.completed) {
        await _fcmService.simulateTripNotification(
          title: 'notification_trip_completed_title',

          body: 'notification_thanks_riding',

          tripId: tripId,

          type: NotificationType.tripCompleted,
        );

        await _authRepository.getProfile(forceRefresh: true);
      }
    } catch (e) {
      emit(DriverActiveTripError(e.toString()));
    }
  }

  Future<void> _onArrived(
    DriverActiveTripArrivedRequested event,

    Emitter<DriverActiveTripState> emit,
  ) => _updateStatus(event.tripId, TripStatus.driverArrived, emit);

  Future<void> _onStart(
    DriverActiveTripStartRequested event,

    Emitter<DriverActiveTripState> emit,
  ) => _updateStatus(event.tripId, TripStatus.inProgress, emit);

  Future<void> _onComplete(
    DriverActiveTripCompleteRequested event,

    Emitter<DriverActiveTripState> emit,
  ) => _updateStatus(event.tripId, TripStatus.completed, emit);

  Future<void> _onLocationUpdate(
    DriverActiveTripLocationUpdateRequested event,

    Emitter<DriverActiveTripState> emit,
  ) async {
    final current = state;

    if (current is! DriverActiveTripLoaded) return;

    try {
      final trip = await _driverTripRepository.updateDriverLocation(
        event.tripId,

        lat: event.lat,

        lng: event.lng,
      );

      emit(current.copyWith(trip: trip));
    } catch (_) {}
  }
}
