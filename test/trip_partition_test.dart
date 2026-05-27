import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TripEntity buildTrip({
    required String id,
    required TripStatus status,
    required DateTime updatedAt,
  }) {
    return TripEntity(
      id: id,
      pickupAddress: 'Pickup $id',
      dropoffAddress: 'Dropoff $id',
      pickupLat: 30.0,
      pickupLng: 31.0,
      dropoffLat: 30.1,
      dropoffLng: 31.1,
      status: status,
      fare: 85,
      createdAt: updatedAt,
      updatedAt: updatedAt,
    );
  }

  group('TripEntityX.isCurrentTrip', () {
    test('returns true for non-terminal statuses', () {
      for (final status in [
        TripStatus.requested,
        TripStatus.accepted,
        TripStatus.driverArrived,
        TripStatus.inProgress,
      ]) {
        final trip = buildTrip(
          id: 'trip',
          status: status,
          updatedAt: DateTime(2026, 5, 25),
        );
        expect(trip.isCurrentTrip, isTrue);
      }
    });

    test('returns false for completed and cancelled', () {
      for (final status in [TripStatus.completed, TripStatus.cancelled]) {
        final trip = buildTrip(
          id: 'trip',
          status: status,
          updatedAt: DateTime(2026, 5, 25),
        );
        expect(trip.isCurrentTrip, isFalse);
      }
    });
  });

  group('partitionTrips', () {
    test('returns empty partition for empty list', () {
      final result = partitionTrips([]);

      expect(result.current, isNull);
      expect(result.history, isEmpty);
    });

    test('selects in-progress trip as current and completed as history', () {
      final completed = buildTrip(
        id: 'trip-001',
        status: TripStatus.completed,
        updatedAt: DateTime(2026, 5, 20, 11, 15),
      );
      final inProgress = buildTrip(
        id: 'trip-002',
        status: TripStatus.inProgress,
        updatedAt: DateTime(2026, 5, 25, 14, 20),
      );

      final result = partitionTrips([completed, inProgress]);

      expect(result.current?.id, 'trip-002');
      expect(result.history.map((trip) => trip.id), ['trip-001']);
    });

    test('picks most recently updated current trip when multiple exist', () {
      final older = buildTrip(
        id: 'trip-a',
        status: TripStatus.accepted,
        updatedAt: DateTime(2026, 5, 24),
      );
      final newer = buildTrip(
        id: 'trip-b',
        status: TripStatus.requested,
        updatedAt: DateTime(2026, 5, 26),
      );

      final result = partitionTrips([older, newer]);

      expect(result.current?.id, 'trip-b');
      expect(result.history.map((trip) => trip.id), ['trip-a']);
    });

    test('returns all trips as history when none are current', () {
      final completed = buildTrip(
        id: 'trip-001',
        status: TripStatus.completed,
        updatedAt: DateTime(2026, 5, 20),
      );
      final cancelled = buildTrip(
        id: 'trip-002',
        status: TripStatus.cancelled,
        updatedAt: DateTime(2026, 5, 21),
      );

      final result = partitionTrips([completed, cancelled]);

      expect(result.current, isNull);
      expect(result.history.map((trip) => trip.id), ['trip-001', 'trip-002']);
    });
  });
}
