import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

abstract class DriverTripRepository {
  Future<List<TripEntity>> getOffers();

  Future<TripEntity> acceptOffer(String tripId);

  Future<void> declineOffer(String tripId);

  Future<TripEntity> updateDriverTripStatus(String tripId, TripStatus status);

  Future<TripEntity> updateDriverLocation(
    String tripId, {
    required double lat,
    required double lng,
  });

  List<TripEntity> getCachedDriverTrips(String driverId);
}
