part of 'driver_offer_preview_cubit.dart';

sealed class DriverOfferPreviewState extends Equatable {
  const DriverOfferPreviewState();

  @override
  List<Object?> get props => [];
}

class DriverOfferPreviewInitial extends DriverOfferPreviewState {
  const DriverOfferPreviewInitial();
}

class DriverOfferPreviewLoading extends DriverOfferPreviewState {
  const DriverOfferPreviewLoading();
}

class DriverOfferPreviewLoaded extends DriverOfferPreviewState {
  const DriverOfferPreviewLoaded({
    required this.trip,
    required this.routePlan,
    this.rider,
  });

  final TripEntity trip;
  final TripRoutePlan routePlan;
  final RiderEntity? rider;

  @override
  List<Object?> get props => [trip.id, routePlan.totalDistanceMeters, rider?.id];
}

class DriverOfferPreviewError extends DriverOfferPreviewState {
  const DriverOfferPreviewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
