import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';

import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';

import 'package:delivery_app/core/sync/app_data_coordinator.dart';

import 'package:delivery_app/core/network/mock_session_context.dart';

import 'package:delivery_app/features/auth/shared/data/datasources/auth_local_datasource.dart';

import 'package:delivery_app/features/driver/shared/data/datasources/driver_trip_remote_datasource.dart';

import 'package:delivery_app/features/trips/shared/data/datasources/trip_local_datasource.dart';

import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';

import 'package:delivery_app/features/driver/shared/domain/repositories/driver_trip_repository.dart';

import 'package:delivery_app/core/network/network_status.dart';

class DriverTripRepositoryImpl implements DriverTripRepository {
  DriverTripRepositoryImpl({
    required DriverTripRemoteDataSource remote,

    required TripLocalDataSource local,

    required AuthLocalDataSource authLocal,

    required NetworkStatus networkStatus,

    required AppDataCoordinator coordinator,

    required PendingSyncLocalDataSource pendingSync,
  }) : _remote = remote,

       _local = local,

       _authLocal = authLocal,

       _networkStatus = networkStatus,

       _coordinator = coordinator,

       _pendingSync = pendingSync;

  final DriverTripRemoteDataSource _remote;

  final TripLocalDataSource _local;

  final AuthLocalDataSource _authLocal;

  final NetworkStatus _networkStatus;

  final AppDataCoordinator _coordinator;

  final PendingSyncLocalDataSource _pendingSync;

  Future<void> _persistTrip(TripEntity trip) async {
    await _local.save(trip);

    _coordinator.notifyTripDataChanged();
  }

  @override
  Future<List<TripEntity>> getOffers() async {
    final driverId =
        MockSessionContext.currentUserId ??
        _authLocal.getCurrentUser()?.id ??
        '';

    if (!await _networkStatus.isOnline) {
      return TripQuery.openOffers(_local.getAll(), driverId);
    }

    final offers = await _remote.fetchOffers();

    for (final offer in offers) {
      await _local.save(offer);
    }

    return offers;
  }

  @override
  Future<TripEntity> acceptOffer(String tripId) async {
    if (!await _networkStatus.isOnline) {
      await _pendingSync.enqueueOrReplace(
        PendingSyncEntity(
          id: 'accept:$tripId',

          action: SyncAction.acceptTripOffer,

          payload: {'tripId': tripId},

          createdAt: DateTime.now(),
        ),
      );

      final existing = _local.getById(tripId);

      if (existing == null) throw StateError('Trip not found: $tripId');

      final user = _authLocal.getCurrentUser();

      final profile = user?.driverProfile;

      final updated = existing.copyWith(
        driverId: user?.id,

        status: TripStatus.accepted,

        driverName: user?.name,

        driverPhone: profile?.phone ?? user?.phone,

        driverAvatarUrl: user?.avatarUrl,

        driverRating: 5.0,

        driverVehicle: profile != null
            ? '${profile.vehicleMakeModel} (${profile.vehicleType})'
            : null,

        isPendingSync: true,

        updatedAt: DateTime.now(),
      );

      await _persistTrip(updated);

      return updated;
    }

    final trip = await _remote.acceptOffer(tripId);

    await _persistTrip(trip.copyWith(isPendingSync: false));

    return trip;
  }

  @override
  Future<void> declineOffer(String tripId) async {
    if (await _networkStatus.isOnline) {
      await _remote.declineOffer(tripId);
    }

    _coordinator.notifyTripDataChanged();
  }

  Future<TripEntity> _queueDriverStatusUpdate(
    String tripId,

    TripStatus status,
  ) async {
    final existing = _local.getById(tripId);

    if (existing == null) throw StateError('Trip not found: $tripId');

    final updated = existing.copyWith(
      status: status,

      isPendingSync: true,

      updatedAt: DateTime.now(),
    );

    await _persistTrip(updated);

    await _pendingSync.enqueueOrReplace(
      PendingSyncEntity(
        id: 'driver-status:$tripId',

        action: SyncAction.updateTripStatus,

        payload: {'tripId': tripId, 'status': status.name, 'driverOwned': true},

        createdAt: DateTime.now(),
      ),
    );

    return updated;
  }

  @override
  Future<TripEntity> updateDriverTripStatus(
    String tripId,

    TripStatus status,
  ) async {
    if (!await _networkStatus.isOnline) {
      return _queueDriverStatusUpdate(tripId, status);
    }

    try {
      final trip = await _remote.updateDriverTripStatus(tripId, status);

      await _persistTrip(trip.copyWith(isPendingSync: false));

      return trip;
    } catch (_) {
      return _queueDriverStatusUpdate(tripId, status);
    }
  }

  @override
  Future<TripEntity> updateDriverLocation(
    String tripId, {

    required double lat,

    required double lng,
  }) async {
    final existing = _local.getById(tripId);

    if (existing == null) throw StateError('Trip not found: $tripId');

    final optimistic = existing.copyWith(
      driverLat: lat,

      driverLng: lng,

      updatedAt: DateTime.now(),
    );

    await _persistTrip(optimistic);

    if (!await _networkStatus.isOnline) {
      await _pendingSync.enqueueOrReplace(
        PendingSyncEntity(
          id: 'driver-location:$tripId',

          action: SyncAction.updateDriverLocation,

          payload: {'tripId': tripId, 'lat': lat, 'lng': lng},

          createdAt: DateTime.now(),
        ),
      );

      return optimistic;
    }

    try {
      final trip = await _remote.updateDriverLocation(
        tripId,

        lat: lat,

        lng: lng,
      );

      await _persistTrip(trip.copyWith(isPendingSync: false));

      await _pendingSync.remove('driver-location:$tripId');

      return trip;
    } catch (_) {
      await _pendingSync.enqueueOrReplace(
        PendingSyncEntity(
          id: 'driver-location:$tripId',

          action: SyncAction.updateDriverLocation,

          payload: {'tripId': tripId, 'lat': lat, 'lng': lng},

          createdAt: DateTime.now(),
        ),
      );

      return optimistic;
    }
  }

  @override
  List<TripEntity> getCachedDriverTrips(String driverId) {
    return TripQuery.forDriver(_local.getAll(), driverId);
  }
}
