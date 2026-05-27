import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_service.dart';
import 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  ConnectivityCubit({required ConnectivityService service})
      : _service = service,
        super(ConnectivityStatus.unknown) {
    _init();
  }

  final ConnectivityService _service;
  StreamSubscription<bool>? _subscription;

  void _init() {
    emit(
      _service.lastKnownStatus
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline,
    );

    _subscription = _service.onConnectivityChanged.listen((isOnline) {
      emit(isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline);
    });
  }

  bool get isOnline => state == ConnectivityStatus.online;

  Future<void> checkConnectivity() async {
    final online = await _service.isOnline;
    emit(online ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
