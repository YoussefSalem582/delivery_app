part of 'driver_offers_bloc.dart';

class DriverOffersState extends Equatable {
  const DriverOffersState();

  @override
  List<Object?> get props => [];
}

class DriverOffersInitial extends DriverOffersState {
  const DriverOffersInitial();
}

class DriverOffersLoading extends DriverOffersState {
  const DriverOffersLoading();
}

class DriverOffersLoaded extends DriverOffersState {
  const DriverOffersLoaded({
    required this.offers,
    this.isRefreshing = false,
    this.isActionInProgress = false,
    this.acceptedTripId,
  });

  final List<TripEntity> offers;
  final bool isRefreshing;
  final bool isActionInProgress;
  final String? acceptedTripId;

  DriverOffersLoaded copyWith({
    List<TripEntity>? offers,
    bool? isRefreshing,
    bool? isActionInProgress,
    String? acceptedTripId,
    bool clearAcceptedTripId = false,
  }) {
    return DriverOffersLoaded(
      offers: offers ?? this.offers,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      acceptedTripId: clearAcceptedTripId
          ? null
          : (acceptedTripId ?? this.acceptedTripId),
    );
  }

  @override
  List<Object?> get props => [
    offers,
    isRefreshing,
    isActionInProgress,
    acceptedTripId,
  ];
}

class DriverOffersError extends DriverOffersState {
  const DriverOffersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
