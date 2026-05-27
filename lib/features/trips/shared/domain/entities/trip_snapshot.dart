import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

bool tripsSnapshotEquals(List<TripEntity> a, List<TripEntity> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;

  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left.id != right.id ||
        left.status != right.status ||
        left.fare != right.fare ||
        left.updatedAt != right.updatedAt ||
        left.distanceKm != right.distanceKm ||
        left.etaMinutes != right.etaMinutes ||
        left.paymentMethodKey != right.paymentMethodKey ||
        left.rideTierKey != right.rideTierKey ||
        left.driverName != right.driverName) {
      return false;
    }
  }

  return true;
}
