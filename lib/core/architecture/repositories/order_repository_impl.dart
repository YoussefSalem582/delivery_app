import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:delivery_app/core/architecture/datasources/cache_metadata_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/order_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/order_remote_datasource.dart';
import 'package:delivery_app/core/architecture/entities/order_entity.dart';
import 'package:delivery_app/core/architecture/repositories/order_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/utils/cache_freshness.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderLocalDataSource local,
    required OrderRemoteDataSource remote,
    required CacheMetadataLocalDataSource cacheMetadata,
    required NetworkStatus networkStatus,
    required Talker talker,
  })  : _local = local,
        _remote = remote,
        _cacheMetadata = cacheMetadata,
        _networkStatus = networkStatus,
        _talker = talker;

  final OrderLocalDataSource _local;
  final OrderRemoteDataSource _remote;
  final CacheMetadataLocalDataSource _cacheMetadata;
  final NetworkStatus _networkStatus;
  final Talker _talker;

  @override
  List<OrderEntity> getCachedOrders() => _local.getAll();

  @override
  Future<List<OrderEntity>> getOrders({bool forceRefresh = false}) async {
    final cached = _local.getAll();
    final lastFetched = _cacheMetadata.getLastFetched(CacheKeys.orders);

    if (!forceRefresh &&
        cached.isNotEmpty &&
        (!await _networkStatus.isOnline ||
            CacheFreshness.isFresh(lastFetched))) {
      return cached;
    }

    if (!await _networkStatus.isOnline) return cached;

    try {
      final remote = await _remote.fetchOrders();
      await _local.saveAll(remote);
      await _cacheMetadata.markFetched(CacheKeys.orders);
      return _local.getAll();
    } on DioException catch (e, st) {
      _talker.handle(e, st, '[OrderRepo] Using cached orders');
      return cached;
    }
  }
}
