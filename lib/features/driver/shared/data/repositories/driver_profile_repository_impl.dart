import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/sync/app_data_coordinator.dart';
import 'package:delivery_app/features/auth/shared/data/datasources/auth_local_datasource.dart';
import 'package:delivery_app/features/driver/shared/data/datasources/driver_profile_remote_datasource.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';
import 'package:delivery_app/features/driver/shared/domain/repositories/driver_profile_repository.dart';
import 'package:delivery_app/core/network/network_status.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  DriverProfileRepositoryImpl({
    required DriverProfileRemoteDataSource remote,
    required AuthLocalDataSource authLocal,
    required NetworkStatus networkStatus,
    required AppDataCoordinator coordinator,
    required PendingSyncLocalDataSource pendingSync,
  }) : _remote = remote,
       _authLocal = authLocal,
       _networkStatus = networkStatus,
       _coordinator = coordinator,
       _pendingSync = pendingSync;

  final DriverProfileRemoteDataSource _remote;
  final AuthLocalDataSource _authLocal;
  final NetworkStatus _networkStatus;
  final AppDataCoordinator _coordinator;
  final PendingSyncLocalDataSource _pendingSync;

  @override
  Future<DriverProfileEntity?> getDriverProfile() async {
    final user = _authLocal.getCurrentUser();
    return user?.driverProfile;
  }

  @override
  Future<DriverProfileEntity> registerDriver({
    required String phone,
    required String vehicleType,
    required String vehicleMakeModel,
    required String licensePlate,
    required bool termsAccepted,
  }) async {
    final current = _authLocal.getCurrentUser();
    if (current == null) {
      throw StateError('No authenticated user');
    }

    if (await _networkStatus.isOnline) {
      final user = await _remote.registerDriver({
        'phone': phone,
        'vehicleType': vehicleType,
        'vehicleMakeModel': vehicleMakeModel,
        'licensePlate': licensePlate,
        'termsAccepted': termsAccepted,
      });
      final updated = user.copyWith(phone: phone, isLoggedIn: true);
      await _authLocal.saveUser(updated);
      _coordinator.notifyUserDataChanged(updated);
      await _pendingSync.remove('register-driver');
      return updated.driverProfile!;
    }

    final profile = DriverProfileEntity(
      phone: phone,
      vehicleType: vehicleType,
      vehicleMakeModel: vehicleMakeModel,
      licensePlate: licensePlate,
      registeredAt: DateTime.now(),
      termsAccepted: termsAccepted,
    );
    final updated = current.copyWith(
      phone: phone,
      isDriverRegistered: true,
      driverProfile: profile,
    );
    await _authLocal.saveUser(updated);
    _coordinator.notifyUserDataChanged(updated);
    await _pendingSync.enqueueOrReplace(
      PendingSyncEntity(
        id: 'register-driver',
        action: SyncAction.registerDriver,
        payload: {
          'phone': phone,
          'vehicleType': vehicleType,
          'vehicleMakeModel': vehicleMakeModel,
          'licensePlate': licensePlate,
          'termsAccepted': termsAccepted,
        },
        createdAt: DateTime.now(),
      ),
    );
    return profile;
  }
}
