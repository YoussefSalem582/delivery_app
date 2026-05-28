import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:delivery_app/core/sync/driver_pending_sync_handler.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/profile/shared/domain/repositories/order_repository.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/trip_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/core/utils/constants.dart';

class SyncService {
  SyncService({
    required TripRepository tripRepository,
    required OrderRepository orderRepository,
    required AuthRepository authRepository,
    required NetworkStatus networkStatus,
    required Talker talker,
    required DriverPendingSyncHandler driverPendingSyncHandler,
    this.onTripsChanged,
  })  : _tripRepository = tripRepository,
        _orderRepository = orderRepository,
        _authRepository = authRepository,
        _networkStatus = networkStatus,
        _talker = talker,
        _driverPendingSyncHandler = driverPendingSyncHandler;

  final TripRepository _tripRepository;
  final OrderRepository _orderRepository;
  final AuthRepository _authRepository;
  final NetworkStatus _networkStatus;
  final Talker _talker;
  final DriverPendingSyncHandler _driverPendingSyncHandler;
  VoidCallback? onTripsChanged;

  StreamSubscription<bool>? _subscription;
  bool _wasOffline = false;

  Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      AppConstants.workmanagerUniqueName,
      AppConstants.workmanagerTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    _wasOffline = !(await _networkStatus.isOnline);
    _subscription = _networkStatus.onOnlineChanged.listen(_onOnlineChanged);
    _talker.info('[SyncService] Initialized with WorkManager + connectivity listener');
  }

  Future<void> _onOnlineChanged(bool isOnline) async {
    if (_wasOffline && isOnline) {
      _talker.info('[SyncService] Reconnected — draining pending sync');
      await syncAll();
    }
    _wasOffline = !isOnline;
  }

  Future<void> syncAll() async {
    await _driverPendingSyncHandler.syncPending();
    await _driverPendingSyncHandler.syncDriverStatusUpdates();
    await _tripRepository.syncPendingChanges();
    await _orderRepository.getOrders(forceRefresh: true);
    await _authRepository.getProfile(forceRefresh: true);
    _talker.info('[SyncService] Sync complete');
    onTripsChanged?.call();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Background sync relies on foreground reconnect in demo;
    // full Hive re-init in isolate is omitted for template simplicity.
    return Future.value(true);
  });
}
