import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';

abstract class DriverRepository {
  Future<List<DriverEntity>> getDrivers();

  Future<DriverEntity?> findByName(String name);
}
