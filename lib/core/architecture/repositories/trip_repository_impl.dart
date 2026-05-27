import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_app/core/architecture/datasources/cache_metadata_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/trip_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/trip_remote_datasource.dart';
import 'package:delivery_app/core/architecture/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/utils/cache_freshness.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({
    required TripLocalDataSource local,
    required TripRemoteDataSource remote,
    required PendingSyncLocalDataSource pendingSync,
    required CacheMetadataLocalDataSource cacheMetadata,
    required NetworkStatus networkStatus,
    required Talker talker,
  })  : _local = local,
        _remote = remote,
        _pendingSync = pendingSync,
        _cacheMetadata = cacheMetadata,
        _networkStatus = networkStatus,
        _talker = talker;

  final TripLocalDataSource _local;
  final TripRemoteDataSource _remote;
  final PendingSyncLocalDataSource _pendingSync;
  final CacheMetadataLocalDataSource _cacheMetadata;
  final NetworkStatus _networkStatus;
  final Talker _talker;
  final _uuid = const Uuid();

  @override
  List<TripEntity> getCachedTrips() => _local.getAll();

  @override
  int getPendingRetryCount(String tripId) {
    var maxRetry = 0;
    for (final item in _pendingSync.getAll()) {
      final matchesTrip = item.id == tripId ||
          item.id == 'status:$tripId' ||
          item.payload['tripId'] == tripId;
      if (matchesTrip && item.retryCount > maxRetry) {
        maxRetry = item.retryCount;
      }
    }
    return maxRetry;
  }

  @override
  Future<List<TripEntity>> getTrips({bool forceRefresh = false}) async {
    final cached = _local.getAll();
    final lastFetched = _cacheMetadata.getLastFetched(CacheKeys.trips);

    if (!forceRefresh &&
        cached.isNotEmpty &&
        (!await _networkStatus.isOnline ||
            CacheFreshness.isFresh(lastFetched))) {
      _talker.info('[TripRepo] Returning ${cached.length} cached trips');
      return cached;
    }

    if (!await _networkStatus.isOnline) {
      return cached;
    }

    try {
      final remote = await _remote.fetchTrips();
      await _local.saveAll(remote);
      await _cacheMetadata.markFetched(CacheKeys.trips);
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

    if (!await _networkStatus.isOnline) return null;

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
    await _pendingSync.enqueueOrReplace(
      PendingSyncEntity(
        id: optimisticId,
        action: SyncAction.createTrip,
        payload: optimisticTrip.toJson(),
        createdAt: now,
      ),
    );

    if (await _networkStatus.isOnline) {
      try {
        final remote = await _remote.requestTrip(optimisticTrip.toJson());
        final synced = remote.copyWith(isPendingSync: false);
        await _local.delete(optimisticId);
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
    final queueId = 'status:$id';
    await _pendingSync.enqueueOrReplace(
      PendingSyncEntity(
        id: queueId,
        action: SyncAction.updateTripStatus,
        payload: {'tripId': id, 'status': status.name},
        createdAt: DateTime.now(),
      ),
    );

    if (await _networkStatus.isOnline) {
      try {
        await _remote.updateStatus(id, status);
        final synced = updated.copyWith(isPendingSync: false);
        await _local.save(synced);
        await _pendingSync.remove(queueId);
        return synced;
      } on DioException catch (e, st) {
        _talker.handle(e, st, '[TripRepo] Status update queued');
      }
    }

    return updated;
  }

  @override
  Future<void> syncPendingChanges() async {
    if (!await _networkStatus.isOnline) return;

    final pending = _pendingSync.getAll();
    for (final item in pending) {
      try {
        switch (item.action) {
          case SyncAction.createTrip:
            final optimisticId = item.id;
            final remote = await _remote.requestTrip(item.payload);
            await _local.delete(optimisticId);
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
        await _pendingSync.enqueueOrReplace(
          item.copyWith(retryCount: item.retryCount + 1),
        );
      }
    }

    await getTrips(forceRefresh: true);
  }
}
