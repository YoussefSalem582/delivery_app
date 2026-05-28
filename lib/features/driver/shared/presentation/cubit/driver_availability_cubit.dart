import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/constants/storage_keys.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_availability.dart';
import 'package:delivery_app/features/driver/shared/data/datasources/driver_profile_remote_datasource.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'driver_availability_state.dart';

class DriverAvailabilityCubit extends Cubit<DriverAvailabilityState> {
  DriverAvailabilityCubit({
    required SharedPreferences sharedPreferences,
    required DriverProfileRemoteDataSource remote,
    required NetworkStatus networkStatus,
    required PendingSyncLocalDataSource pendingSync,
  }) : _prefs = sharedPreferences,
       _remote = remote,
       _networkStatus = networkStatus,
       _pendingSync = pendingSync,
       super(const DriverAvailabilityState()) {
    _restore();
  }

  final SharedPreferences _prefs;
  final DriverProfileRemoteDataSource _remote;
  final NetworkStatus _networkStatus;
  final PendingSyncLocalDataSource _pendingSync;

  void _restore() {
    final stored = _prefs.getString(StorageKeys.driverAvailability);
    if (stored != null) {
      final availability = DriverAvailability.values.firstWhere(
        (e) => e.storageKey == stored,
        orElse: () => DriverAvailability.offline,
      );
      emit(state.copyWith(availability: availability));
    }
  }

  Future<void> setAvailability(DriverAvailability availability) async {
    emit(state.copyWith(availability: availability, isUpdating: true));
    await _prefs.setString(
      StorageKeys.driverAvailability,
      availability.storageKey,
    );

    if (await _networkStatus.isOnline) {
      try {
        await _remote.updateAvailability(availability.storageKey);
        await _pendingSync.remove('driver-availability');
      } catch (_) {
        await _enqueueAvailability(availability);
      }
    } else {
      await _enqueueAvailability(availability);
    }

    emit(state.copyWith(isUpdating: false));
  }

  Future<void> _enqueueAvailability(DriverAvailability availability) async {
    await _pendingSync.enqueueOrReplace(
      PendingSyncEntity(
        id: 'driver-availability',
        action: SyncAction.updateDriverAvailability,
        payload: {'status': availability.storageKey},
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> goOnline() => setAvailability(DriverAvailability.online);

  Future<void> goOffline() => setAvailability(DriverAvailability.offline);

  void lockOnTrip() {
    emit(state.copyWith(availability: DriverAvailability.onTrip));
    _prefs.setString(
      StorageKeys.driverAvailability,
      DriverAvailability.onTrip.storageKey,
    );
  }
}
