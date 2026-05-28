import 'dart:io';

import 'package:delivery_app/core/cache/entities/hive_adapters.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('nokta_hive_test');
    Hive
      ..init(tempDir.path)
      ..registerAdapter(TripStatusAdapter())
      ..registerAdapter(TripEntityAdapter())
      ..registerAdapter(UserEntityAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('UserEntity Hive round-trip', () {
    test('persists driver profile fields', () async {
      final box = await Hive.openBox<UserEntity>('user_test');
      final user = UserEntity(
        id: 'user-001',
        name: 'Demo Rider',
        email: 'demo@nokta.app',
        phone: '+201000000001',
        walletBalance: 250,
        isDriverRegistered: true,
        driverProfile: DriverProfileEntity(
          phone: '+201000000001',
          vehicleType: 'economy',
          vehicleMakeModel: 'Toyota Corolla',
          licensePlate: 'ABC 123',
          registeredAt: DateTime.utc(2026, 1, 15),
          termsAccepted: true,
        ),
      );

      await box.put('current_user', user);
      final restored = box.get('current_user');

      expect(restored, isNotNull);
      expect(restored!.isDriverRegistered, isTrue);
      expect(restored.driverProfile?.vehicleType, 'economy');
      expect(restored.driverProfile?.licensePlate, 'ABC 123');
      await box.close();
    });
  });

  group('TripEntity Hive round-trip', () {
    test('persists riderId driverId and driver location', () async {
      final box = await Hive.openBox<TripEntity>('trips_test');
      final trip = TripEntity(
        id: 'trip-001',
        pickupAddress: 'Pickup',
        dropoffAddress: 'Dropoff',
        pickupLat: 30.04,
        pickupLng: 31.23,
        dropoffLat: 30.06,
        dropoffLng: 31.25,
        status: TripStatus.accepted,
        riderId: 'user-rider',
        driverId: 'user-driver',
        driverLat: 30.045,
        driverLng: 31.235,
        fare: 85,
        createdAt: DateTime.utc(2026, 5, 1),
        updatedAt: DateTime.utc(2026, 5, 1, 0, 5),
      );

      await box.put(trip.id, trip);
      final restored = box.get(trip.id);

      expect(restored, isNotNull);
      expect(restored!.riderId, 'user-rider');
      expect(restored.driverId, 'user-driver');
      expect(restored.driverLat, 30.045);
      expect(restored.driverLng, 31.235);
      await box.close();
    });
  });
}
