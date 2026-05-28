import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

extension TripEntityX on TripEntity {
  bool get isCurrentTrip =>
      status != TripStatus.completed && status != TripStatus.cancelled;
}

typedef TripPartition = ({TripEntity? current, List<TripEntity> history});

TripPartition partitionTrips(List<TripEntity> trips) {
  if (trips.isEmpty) {
    return (current: null, history: const []);
  }

  final currentCandidates =
      trips.where((trip) => trip.isCurrentTrip).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  final current = currentCandidates.isEmpty ? null : currentCandidates.first;
  final history = trips.where((trip) => trip.id != current?.id).toList();

  return (current: current, history: history);
}

abstract final class TripQuery {
  static List<TripEntity> forRider(List<TripEntity> trips, String riderId) {
    return trips.where((trip) => trip.riderId == riderId).toList();
  }

  static List<TripEntity> forDriver(List<TripEntity> trips, String driverId) {
    return trips
        .where((trip) => trip.driverId == driverId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static List<TripEntity> openOffers(
    List<TripEntity> trips,
    String driverUserId,
  ) {
    return trips.where((trip) {
      return trip.status == TripStatus.requested &&
          trip.driverId == null &&
          trip.riderId != driverUserId;
    }).toList();
  }

  static TripEntity? activeDriverTrip(
    List<TripEntity> trips,
    String driverId,
  ) {
    final candidates = trips
        .where(
          (trip) => trip.driverId == driverId && trip.isCurrentTrip,
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return candidates.isEmpty ? null : candidates.first;
  }

  static double completedDriverEarnings(
    List<TripEntity> trips,
    String driverId,
  ) {
    return trips
        .where(
          (trip) =>
              trip.driverId == driverId && trip.status == TripStatus.completed,
        )
        .fold(0.0, (sum, trip) => sum + trip.fare);
  }
}
