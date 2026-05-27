import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/network/fcm_service.dart';

part 'trip_detail_event.dart';
part 'trip_detail_state.dart';

class TripDetailBloc extends Bloc<TripDetailEvent, TripDetailState> {
  TripDetailBloc({
    required TripRepository repository,
    required AuthRepository authRepository,
    required FcmService fcmService,
  })  : _repository = repository,
        _authRepository = authRepository,
        _fcmService = fcmService,
        super(const TripDetailInitial()) {
    on<TripDetailLoadRequested>(_onLoad);
    on<TripDetailStatusUpdateRequested>(_onStatusUpdate);
    on<TripDetailCompleteRequested>(_onComplete);
  }

  final TripRepository _repository;
  final AuthRepository _authRepository;
  final FcmService _fcmService;

  Future<void> _onLoad(
    TripDetailLoadRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    final cachedMatches =
        _repository.getCachedTrips().where((t) => t.id == event.tripId);
    final cached = cachedMatches.isEmpty ? null : cachedMatches.first;
    if (cached != null) {
      emit(TripDetailLoaded(cached));
    } else {
      emit(const TripDetailLoading());
    }
    try {
      final trip = await _repository.getTripById(event.tripId);
      if (trip == null) {
        emit(const TripDetailError('Trip not found'));
        return;
      }
      emit(TripDetailLoaded(trip));
    } catch (e) {
      emit(TripDetailError(e.toString()));
    }
  }

  Future<void> _onStatusUpdate(
    TripDetailStatusUpdateRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    try {
      final trip = await _repository.updateTripStatus(
        event.tripId,
        event.status,
      );
      emit(TripDetailLoaded(trip));
      if (event.status == TripStatus.driverArrived) {
        await _fcmService.simulateTripNotification(
          title: 'notification_trip_update',
          body: 'notification_driver_arrived',
          tripId: trip.id,
        );
      }
    } catch (e) {
      emit(TripDetailError(e.toString()));
    }
  }

  Future<void> _onComplete(
    TripDetailCompleteRequested event,
    Emitter<TripDetailState> emit,
  ) async {
    try {
      final current = state is TripDetailLoaded
          ? (state as TripDetailLoaded).trip
          : await _repository.getTripById(event.tripId);
      if (current == null) {
        emit(const TripDetailError('Trip not found'));
        return;
      }

      final trip = await _repository.updateTripStatus(
        event.tripId,
        TripStatus.completed,
      );
      await _authRepository.updateWalletBalance(-current.fare);
      await _fcmService.simulateTripNotification(
        title: 'notification_trip_update',
        body: 'status_completed',
        tripId: trip.id,
      );
      emit(TripDetailLoaded(trip));
    } catch (e) {
      emit(TripDetailError(e.toString()));
    }
  }
}
