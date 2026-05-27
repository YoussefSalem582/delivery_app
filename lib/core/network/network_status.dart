import 'package:connectivity_plus/connectivity_plus.dart';

/// Link-type connectivity only; Wi‑Fi without internet may still report online.
class NetworkStatus {
  NetworkStatus(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<bool> get onOnlineChanged async* {
    yield await isOnline;
    await for (final result in _connectivity.onConnectivityChanged) {
      yield !result.contains(ConnectivityResult.none);
    }
  }
}
