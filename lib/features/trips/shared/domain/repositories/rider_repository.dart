import 'package:delivery_app/features/trips/shared/domain/entities/rider_entity.dart';

abstract class RiderRepository {
  Future<List<RiderEntity>> getRiders();

  Future<RiderEntity?> findById(String id);
}
