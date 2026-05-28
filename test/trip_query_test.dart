import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final riderTrip = TripEntity(
    id: 't1',
    pickupAddress: 'A',
    dropoffAddress: 'B',
    pickupLat: 1,
    pickupLng: 1,
    dropoffLat: 2,
    dropoffLng: 2,
    status: TripStatus.requested,
    riderId: 'user-001',
    fare: 10,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final driverTrip = riderTrip.copyWith(
    id: 't2',
    driverId: 'user-001',
    riderId: 'user-002',
    status: TripStatus.accepted,
  );

  test('TripQuery.forRider filters by riderId', () {
    final result = TripQuery.forRider([riderTrip, driverTrip], 'user-001');
    expect(result.length, 1);
    expect(result.first.id, 't1');
  });

  test('TripQuery.forDriver filters by driverId', () {
    final result = TripQuery.forDriver([riderTrip, driverTrip], 'user-001');
    expect(result.length, 1);
    expect(result.first.id, 't2');
  });

  test('TripQuery.openOffers excludes own trips', () {
    final result = TripQuery.openOffers([riderTrip, driverTrip], 'user-001');
    expect(result, isEmpty);
  });
}
