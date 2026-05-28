import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_payment.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';

part 'trip_detail_event.dart';
part 'trip_detail_state.dart';

class TripDetailBloc extends Bloc<TripDetailEvent, TripDetailState> {
  TripDetailBloc({
    required GetCachedTripDetailUseCase getCachedTripDetail,
    required GetTripDetailUseCase getTripDetail,
    required UpdateTripStatusUseCase updateTripStatus,
    required AuthRepository authRepository,
    required FcmService fcmService,
    VoidCallback? onTripsChanged,
  })  : _getCachedTripDetail = getCachedTripDetail,
        _getTripDetail = getTripDetail,
        _updateTripStatus = updateTripStatus,
        _authRepository = authRepository,
        _fcmService = fcmService,
        _onTripsChanged = onTripsChanged,
        super(const TripDetailInitial()) {
    on<TripDetailLoadRequested>(_onLoad);
    on<TripDetailStatusUpdateRequested>(_onStatusUpdate);
    on<TripDetailCompleteRequested>(_onComplete);
  }

  final GetCachedTripDetailUseCase _getCachedTripDetail;
  final GetTripDetailUseCase _getTripDetail;
  final UpdateTripStatusUseCase _updateTripStatus;
  final AuthRepository _authRepository;
  final FcmService _fcmService;
  final VoidCallback? _onTripsChanged;

  Future<void> _onLoad(
    TripDetailLoadRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    final cachedResult = await _getCachedTripDetail(
      GetCachedTripDetailParams(event.tripId),
    );
    cachedResult.fold(
      (_) {},
      (cached) {
        if (cached != null) emit(TripDetailLoaded(cached));
      },
    );
    if (state is! TripDetailLoaded) {
      emit(const TripDetailLoading());
    }
    final result = await _getTripDetail(GetTripDetailParams(event.tripId));
    result.fold(
      (Failure failure) => emit(TripDetailError(failure.message)),
      (trip) => emit(TripDetailLoaded(trip)),
    );
  }

  Future<void> _onStatusUpdate(
    TripDetailStatusUpdateRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    final result = await _updateTripStatus(
      UpdateTripStatusParams(tripId: event.tripId, status: event.status),
    );
    await result.fold(
      (Failure failure) async => emit(TripDetailError(failure.message)),
      (trip) async {
        emit(TripDetailLoaded(trip));
        if (event.status == TripStatus.driverArrived) {
          await _fcmService.simulateTripNotification(
            title: 'notification_trip_update',
            body: 'notification_driver_arrived',
            tripId: trip.id,
            type: NotificationType.driverArrived,
          );
        }
        _onTripsChanged?.call();
      },
    );
  }

  Future<void> _onComplete(
    TripDetailCompleteRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    TripEntity? current;
    if (state is TripDetailLoaded) {
      current = (state as TripDetailLoaded).trip;
    } else {
      final result = await _getTripDetail(GetTripDetailParams(event.tripId));
      result.fold((_) => current = null, (trip) => current = trip);
    }
    if (current == null) {
      emit(const TripDetailError('Trip not found'));
      return;
    }

    final result = await _updateTripStatus(
      UpdateTripStatusParams(
        tripId: event.tripId,
        status: TripStatus.completed,
      ),
    );
    await result.fold(
      (Failure failure) async => emit(TripDetailError(failure.message)),
      (trip) async {
        if (tripUsesWallet(trip.paymentMethodKey)) {
          await _authRepository.updateWalletBalance(-current!.fare);
        }
        await _fcmService.simulateTripNotification(
          title: 'notification_trip_update',
          body: 'status_completed',
          tripId: trip.id,
          type: NotificationType.tripCompleted,
        );
        _onTripsChanged?.call();
        emit(TripDetailLoaded(trip));
      },
    );
  }
}
