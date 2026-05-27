import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'network_status.dart';

/// Wraps [NetworkStatus] and exposes a broadcast stream of online/offline changes.
class ConnectivityService {
  ConnectivityService(this._networkStatus);

  final NetworkStatus _networkStatus;
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _lastKnownStatus = true;

  bool get lastKnownStatus => _lastKnownStatus;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<void> init() async {
    _lastKnownStatus = await _networkStatus.isOnline;
    _subscription = Connectivity().onConnectivityChanged.listen((_) async {
      final online = await _networkStatus.isOnline;
      if (online != _lastKnownStatus) {
        _lastKnownStatus = online;
        _controller.add(online);
      }
    });
  }

  Future<bool> get isOnline => _networkStatus.isOnline;

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
