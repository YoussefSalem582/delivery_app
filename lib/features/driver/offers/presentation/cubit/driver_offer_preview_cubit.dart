import 'package:delivery_app/core/network/route_service.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/rider_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/get_rider_for_trip_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

part 'driver_offer_preview_state.dart';

class DriverOfferPreviewCubit extends Cubit<DriverOfferPreviewState> {
  DriverOfferPreviewCubit({
    required RouteService routeService,
    required GetRiderForTripUseCase getRiderForTrip,
  })  : _routeService = routeService,
        _getRiderForTrip = getRiderForTrip,
        super(const DriverOfferPreviewInitial());

  final RouteService _routeService;
  final GetRiderForTripUseCase _getRiderForTrip;

  Future<void> load(TripEntity trip) async {
    emit(const DriverOfferPreviewLoading());

    try {
      final pickup = LatLng(trip.pickupLat, trip.pickupLng);
      final dropoff = LatLng(trip.dropoffLat, trip.dropoffLng);

      final routePlan = await _routeService.getTripRoutePlan(
        pickup: pickup,
        dropoff: dropoff,
        placementSeed: trip.id,
      );

      RiderEntity? rider;
      final riderResult = await _getRiderForTrip(
        GetRiderForTripParams(riderId: trip.riderId),
      );
      riderResult.fold((_) {}, (value) => rider = value);

      emit(
        DriverOfferPreviewLoaded(
          trip: trip,
          routePlan: routePlan,
          rider: rider,
        ),
      );
    } catch (e) {
      emit(DriverOfferPreviewError(e.toString()));
    }
  }
}
