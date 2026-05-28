import 'package:delivery_app/core/network/fcm_service.dart';

import 'package:delivery_app/features/driver/shared/domain/repositories/driver_trip_repository.dart';

import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';

import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_offers_event.dart';

part 'driver_offers_state.dart';

class DriverOffersBloc extends Bloc<DriverOffersEvent, DriverOffersState> {
  DriverOffersBloc({
    required DriverTripRepository driverTripRepository,

    required FcmService fcmService,
  }) : _driverTripRepository = driverTripRepository,

       _fcmService = fcmService,

       super(const DriverOffersInitial()) {
    on<DriverOffersLoadRequested>(_onLoad);

    on<DriverOffersRefreshRequested>(_onRefresh);

    on<DriverOffersAcceptRequested>(_onAccept);

    on<DriverOffersDeclineRequested>(_onDecline);
  }

  final DriverTripRepository _driverTripRepository;

  final FcmService _fcmService;

  final Set<String> _knownOfferIds = {};

  Future<void> _onLoad(
    DriverOffersLoadRequested event,

    Emitter<DriverOffersState> emit,
  ) async {
    emit(const DriverOffersLoading());

    await _fetchOffers(emit);
  }

  Future<void> _onRefresh(
    DriverOffersRefreshRequested event,

    Emitter<DriverOffersState> emit,
  ) async {
    final current = state;

    if (current is DriverOffersLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const DriverOffersLoading());
    }

    await _fetchOffers(emit);
  }

  Future<void> _notifyNewOffers(List<TripEntity> offers) async {
    for (final offer in offers) {
      if (_knownOfferIds.contains(offer.id)) continue;

      await _fcmService.simulateTripNotification(
        title: 'notification_trip_update',

        body: 'notification_driver_offer',

        tripId: offer.id,

        type: NotificationType.tripUpdate,
      );
    }

    _knownOfferIds
      ..clear()
      ..addAll(offers.map((o) => o.id));
  }

  Future<void> _fetchOffers(Emitter<DriverOffersState> emit) async {
    try {
      final offers = await _driverTripRepository.getOffers();

      await _notifyNewOffers(offers);

      emit(DriverOffersLoaded(offers: offers));
    } catch (e) {
      emit(DriverOffersError(e.toString()));
    }
  }

  Future<void> _onAccept(
    DriverOffersAcceptRequested event,

    Emitter<DriverOffersState> emit,
  ) async {
    final current = state;

    if (current is! DriverOffersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _driverTripRepository.acceptOffer(event.tripId);

      await _fcmService.simulateTripNotification(
        title: 'notification_trip_update',

        body: 'notification_trip_accepted',

        tripId: event.tripId,

        type: NotificationType.tripAccepted,
      );

      final offers = await _driverTripRepository.getOffers();

      emit(DriverOffersLoaded(offers: offers, acceptedTripId: event.tripId));
    } catch (e) {
      emit(DriverOffersError(e.toString()));
    }
  }

  Future<void> _onDecline(
    DriverOffersDeclineRequested event,

    Emitter<DriverOffersState> emit,
  ) async {
    final current = state;

    if (current is! DriverOffersLoaded) return;

    emit(current.copyWith(isActionInProgress: true));

    try {
      await _driverTripRepository.declineOffer(event.tripId);

      final offers = current.offers
          .where((offer) => offer.id != event.tripId)
          .toList();

      _knownOfferIds.remove(event.tripId);

      emit(DriverOffersLoaded(offers: offers));
    } catch (e) {
      emit(DriverOffersError(e.toString()));
    }
  }
}
