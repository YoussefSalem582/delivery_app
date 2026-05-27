import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_app/core/architecture/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/trip_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/trip_remote_datasource.dart';
import 'package:delivery_app/core/architecture/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({
    required TripLocalDataSource local,
    required TripRemoteDataSource remote,
    required PendingSyncLocalDataSource pendingSync,
    required Connectivity connectivity,
    required Talker talker,
  })  : _local = local,
        _remote = remote,
        _pendingSync = pendingSync,
        _connectivity = connectivity,
        _talker = talker;

  final TripLocalDataSource _local;
  final TripRemoteDataSource _remote;
  final PendingSyncLocalDataSource _pendingSync;
  final Connectivity _connectivity;
  final Talker _talker;
  final _uuid = const Uuid();

  @override
  List<TripEntity> getCachedTrips() => _local.getAll();

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<List<TripEntity>> getTrips({bool forceRefresh = false}) async {
    final cached = _local.getAll();
    if (!forceRefresh && cached.isNotEmpty && !await _isOnline()) {
      _talker.info('[TripRepo] Returning ${cached.length} cached trips (offline)');
      return cached;
    }

    if (!await _isOnline()) {
      return cached;
    }

    try {
      final remote = await _remote.fetchTrips();
      await _local.saveAll(remote);
      _talker.info('[TripRepo] Synced ${remote.length} trips from remote');
      return _local.getAll();
    } on DioException catch (e, st) {
      _talker.handle(e, st, '[TripRepo] Remote fetch failed, using cache');
      return cached;
    }
  }

  @override
  Future<TripEntity?> getTripById(String id) async {
    final cached = _local.getById(id);
    if (cached != null) return cached;

    if (!await _isOnline()) return null;

    try {
      final remote = await _remote.fetchTripById(id);
      await _local.save(remote);
      return remote;
    } catch (_) {
      return cached;
    }
  }

  @override
  Future<TripEntity> requestTrip({
    required String pickupAddress,
    required String dropoffAddress,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    final now = DateTime.now();
    final optimisticId = _uuid.v4();
    final optimisticTrip = TripEntity(
      id: optimisticId,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      status: TripStatus.requested,
      fare: 75,
      createdAt: now,
      updatedAt: now,
      isPendingSync: true,
    );

    await _local.save(optimisticTrip);
    await _pendingSync.enqueue(
      PendingSyncEntity(
        id: optimisticId,
        action: SyncAction.createTrip,
        payload: optimisticTrip.toJson(),
        createdAt: now,
      ),
    );

    if (await _isOnline()) {
      try {
        final remote = await _remote.requestTrip(optimisticTrip.toJson());
        final synced = remote.copyWith(isPendingSync: false);
        await _local.save(synced);
        await _pendingSync.remove(optimisticId);
        return synced;
      } on DioException catch (e, st) {
        _talker.handle(e, st, '[TripRepo] Request queued for sync');
        return optimisticTrip;
      }
    }

    return optimisticTrip;
  }

  @override
  Future<TripEntity> updateTripStatus(String id, TripStatus status) async {
    final existing = _local.getById(id);
    if (existing == null) {
      throw StateError('Trip not found: $id');
    }

    final updated = existing.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      isPendingSync: true,
    );
    await _local.save(updated);
    await _pendingSync.enqueue(
      PendingSyncEntity(
        id: _uuid.v4(),
        action: SyncAction.updateTripStatus,
        payload: {'tripId': id, 'status': status.name},
        createdAt: DateTime.now(),
      ),
    );

    if (await _isOnline()) {
      try {
        await _remote.updateStatus(id, status);
        final synced = updated.copyWith(isPendingSync: false);
        await _local.save(synced);
      } on DioException catch (e, st) {
        _talker.handle(e, st, '[TripRepo] Status update queued');
      }
    }

    return updated;
  }

  @override
  Future<void> syncPendingChanges() async {
    if (!await _isOnline()) return;

    final pending = _pendingSync.getAll();
    for (final item in pending) {
      try {
        switch (item.action) {
          case SyncAction.createTrip:
            final remote = await _remote.requestTrip(item.payload);
            await _local.save(remote.copyWith(isPendingSync: false));
          case SyncAction.updateTripStatus:
            final tripId = item.payload['tripId'] as String;
            final statusName = item.payload['status'] as String;
            final status = TripStatus.values.firstWhere(
              (e) => e.name == statusName,
            );
            await _remote.updateStatus(tripId, status);
            final existing = _local.getById(tripId);
            if (existing != null) {
              await _local.save(
                existing.copyWith(
                  status: status,
                  isPendingSync: false,
                  updatedAt: DateTime.now(),
                ),
              );
            }
        }
        await _pendingSync.remove(item.id);
        _talker.info('[TripRepo] Synced pending item ${item.id}');
      } catch (e, st) {
        _talker.handle(e, st, '[TripRepo] Failed to sync ${item.id}');
      }
    }

    await getTrips(forceRefresh: true);
  }
}
