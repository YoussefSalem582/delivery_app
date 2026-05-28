part of 'driver_offers_bloc.dart';

abstract class DriverOffersEvent extends Equatable {
  const DriverOffersEvent();

  @override
  List<Object?> get props => [];
}

class DriverOffersLoadRequested extends DriverOffersEvent {
  const DriverOffersLoadRequested();
}

class DriverOffersRefreshRequested extends DriverOffersEvent {
  const DriverOffersRefreshRequested();
}

class DriverOffersAcceptRequested extends DriverOffersEvent {
  const DriverOffersAcceptRequested({required this.tripId});

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class DriverOffersDeclineRequested extends DriverOffersEvent {
  const DriverOffersDeclineRequested({required this.tripId});

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}
