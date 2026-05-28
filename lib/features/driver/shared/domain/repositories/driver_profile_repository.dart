import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';

abstract class DriverProfileRepository {
  Future<DriverProfileEntity?> getDriverProfile();

  Future<DriverProfileEntity> registerDriver({
    required String phone,
    required String vehicleType,
    required String vehicleMakeModel,
    required String licensePlate,
    required bool termsAccepted,
  });
}
