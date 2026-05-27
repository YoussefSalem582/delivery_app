import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/core/network/network_status.dart';

class OfflineCubit extends Cubit<bool> {
  OfflineCubit(this._networkStatus) : super(false) {
    _subscription = _networkStatus.onOnlineChanged.listen((online) {
      emit(!online);
    });
  }

  final NetworkStatus _networkStatus;
  StreamSubscription<bool>? _subscription;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
