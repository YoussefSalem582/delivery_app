import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

abstract class TripRepository {
  Future<List<TripEntity>> getTrips({bool forceRefresh = false});
  Future<TripEntity?> getTripById(String id);
  Future<TripEntity> requestTrip({
    required String pickupAddress,
    required String dropoffAddress,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required double fare,
    required String riderId,
    double? distanceKm,
    int? etaMinutes,
    String? paymentMethodKey,
    String? rideTierKey,
  });
  Future<TripEntity> updateTripStatus(String id, TripStatus status);
  Future<TripEntity> updateDriverLocation(
    String id, {
    required double lat,
    required double lng,
  });
  Future<void> syncPendingChanges();
  List<TripEntity> getCachedTrips();
  int getPendingRetryCount(String tripId);
}
