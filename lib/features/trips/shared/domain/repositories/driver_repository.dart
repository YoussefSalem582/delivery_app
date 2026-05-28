import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_review_entity.dart';

abstract class DriverRepository {
  Future<List<DriverEntity>> getDrivers();

  Future<DriverEntity?> findByName(String name);

  Future<DriverEntity?> findById(String id);

  Future<List<DriverReviewEntity>> getReviews(String driverId);
}
