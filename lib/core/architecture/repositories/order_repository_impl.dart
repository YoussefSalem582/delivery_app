import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:delivery_app/core/architecture/datasources/order_local_datasource.dart';
import 'package:delivery_app/core/architecture/datasources/order_remote_datasource.dart';
import 'package:delivery_app/core/architecture/entities/order_entity.dart';
import 'package:delivery_app/core/architecture/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderLocalDataSource local,
    required OrderRemoteDataSource remote,
    required Connectivity connectivity,
    required Talker talker,
  })  : _local = local,
        _remote = remote,
        _connectivity = connectivity,
        _talker = talker;

  final OrderLocalDataSource _local;
  final OrderRemoteDataSource _remote;
  final Connectivity _connectivity;
  final Talker _talker;

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  List<OrderEntity> getCachedOrders() => _local.getAll();

  @override
  Future<List<OrderEntity>> getOrders({bool forceRefresh = false}) async {
    final cached = _local.getAll();
    if (!forceRefresh && cached.isNotEmpty && !await _isOnline()) {
      return cached;
    }

    if (!await _isOnline()) return cached;

    try {
      final remote = await _remote.fetchOrders();
      await _local.saveAll(remote);
      return _local.getAll();
    } on DioException catch (e, st) {
      _talker.handle(e, st, '[OrderRepo] Using cached orders');
      return cached;
    }
  }
}
