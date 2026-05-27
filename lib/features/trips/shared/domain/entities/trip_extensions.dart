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
