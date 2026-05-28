import 'package:talker_flutter/talker_flutter.dart';
import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/sync/app_data_coordinator.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app/features/driver/shared/data/datasources/driver_profile_remote_datasource.dart';
import 'package:delivery_app/features/driver/shared/data/datasources/driver_trip_remote_datasource.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';
import 'package:delivery_app/features/trips/shared/data/datasources/trip_local_datasource.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';

/// Drains driver-specific pending sync actions from the shared queue.
class DriverPendingSyncHandler {
  DriverPendingSyncHandler({
    required PendingSyncLocalDataSource pendingSync,
    required DriverProfileRemoteDataSource driverProfileRemote,
    required DriverTripRemoteDataSource driverTripRemote,
    required AuthLocalDataSource authLocal,
    required TripLocalDataSource tripLocal,
    required AppDataCoordinator coordinator,
    required Talker talker,
  })  : _pendingSync = pendingSync,
        _driverProfileRemote = driverProfileRemote,
        _driverTripRemote = driverTripRemote,
        _authLocal = authLocal,
        _tripLocal = tripLocal,
        _coordinator = coordinator,
        _talker = talker;

  final PendingSyncLocalDataSource _pendingSync;
  final DriverProfileRemoteDataSource _driverProfileRemote;
  final DriverTripRemoteDataSource _driverTripRemote;
  final AuthLocalDataSource _authLocal;
  final TripLocalDataSource _tripLocal;
  final AppDataCoordinator _coordinator;
  final Talker _talker;

  static bool isDriverAction(SyncAction action) {
    return switch (action) {
      SyncAction.registerDriver ||
      SyncAction.acceptTripOffer ||
      SyncAction.updateDriverAvailability ||
      SyncAction.updateDriverLocation =>
        true,
      _ => false,
    };
  }

  Future<void> syncPending() async {
    for (final item in _pendingSync.getAll()) {
      if (!isDriverAction(item.action)) continue;

      try {
        switch (item.action) {
          case SyncAction.registerDriver:
            final user = await _driverProfileRemote.registerDriver(item.payload);
            await _authLocal.saveUser(
              user.copyWith(isLoggedIn: true, phone: item.payload['phone'] as String),
            );
            _coordinator.notifyUserDataChanged(
              _authLocal.getCurrentUser()!,
            );
          case SyncAction.acceptTripOffer:
            final tripId = item.payload['tripId'] as String;
            final trip = await _driverTripRemote.acceptOffer(tripId);
            await _tripLocal.save(trip.copyWith(isPendingSync: false));
            _coordinator.notifyTripDataChanged();
          case SyncAction.updateDriverAvailability:
            final status = item.payload['status'] as String;
            await _driverProfileRemote.updateAvailability(status);
          case SyncAction.updateDriverLocation:
            final tripId = item.payload['tripId'] as String;
            final lat = (item.payload['lat'] as num).toDouble();
            final lng = (item.payload['lng'] as num).toDouble();
            final trip = await _driverTripRemote.updateDriverLocation(
              tripId,
              lat: lat,
              lng: lng,
            );
            await _tripLocal.save(trip.copyWith(isPendingSync: false));
            _coordinator.notifyTripDataChanged();
          case SyncAction.createTrip:
          case SyncAction.updateTripStatus:
            break;
        }
        await _pendingSync.remove(item.id);
        _talker.info('[DriverSync] Synced pending item ${item.id}');
      } catch (e, st) {
        _talker.handle(e, st, '[DriverSync] Failed to sync ${item.id}');
        await _pendingSync.enqueueOrReplace(
          item.copyWith(retryCount: item.retryCount + 1),
        );
      }
    }
  }

  /// Driver-owned status updates use [SyncAction.updateTripStatus] with
  /// `driverOwned: true` in the payload.
  Future<void> syncDriverStatusUpdates() async {
    for (final item in _pendingSync.getAll()) {
      if (item.action != SyncAction.updateTripStatus) continue;
      if (item.payload['driverOwned'] != true) continue;

      try {
        final tripId = item.payload['tripId'] as String;
        final statusName = item.payload['status'] as String;
        final status = TripStatus.values.firstWhere((e) => e.name == statusName);
        final trip = await _driverTripRemote.updateDriverTripStatus(tripId, status);
        await _tripLocal.save(trip.copyWith(isPendingSync: false));
        await _pendingSync.remove(item.id);
        _coordinator.notifyTripDataChanged();
        _talker.info('[DriverSync] Synced driver status ${item.id}');
      } catch (e, st) {
        _talker.handle(e, st, '[DriverSync] Failed driver status ${item.id}');
        await _pendingSync.enqueueOrReplace(
          item.copyWith(retryCount: item.retryCount + 1),
        );
      }
    }
  }
}
