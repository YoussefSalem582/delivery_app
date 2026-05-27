import 'dart:async';

import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/utils/constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

part 'map_event.dart';

class RequestRideBloc extends Bloc<RequestRideEvent, RequestRideState> {
  RequestRideBloc({
    required RequestTripUseCase requestTrip,
    required FcmService fcmService,
  })  : _requestTrip = requestTrip,
        _fcmService = fcmService,
        super(const RequestRideInitial()) {
    on<RequestRideSubmitted>(_onSubmit);
  }

  final RequestTripUseCase _requestTrip;
  final FcmService _fcmService;

  Future<void> _onSubmit(
    RequestRideSubmitted event,
    Emitter<RequestRideState> emit,
  ) async {
    emit(const RequestRideLoading());
    final result = await _requestTrip(
      RequestTripParams(
        pickupAddress: event.pickupAddress,
        dropoffAddress: event.dropoffAddress,
        pickupLat: event.pickupLat,
        pickupLng: event.pickupLng,
        dropoffLat: event.dropoffLat,
        dropoffLng: event.dropoffLng,
      ),
    );
    await result.fold(
      (failure) async => emit(RequestRideError(failure.message)),
      (trip) async {
        await _fcmService.simulateTripNotification(
          title: 'notification_trip_update',
          body: 'notification_trip_accepted',
          tripId: trip.id,
        );
        emit(RequestRideSuccess(trip));
      },
    );
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
