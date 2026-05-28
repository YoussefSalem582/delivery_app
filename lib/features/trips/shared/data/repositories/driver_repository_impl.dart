import 'package:delivery_app/features/trips/shared/data/datasources/driver_remote_datasource.dart';
import 'package:delivery_app/features/trips/shared/data/datasources/driver_review_remote_datasource.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/driver_review_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl(this._remote, this._reviewRemote);

  final DriverRemoteDataSource _remote;
  final DriverReviewRemoteDataSource _reviewRemote;
  List<DriverEntity>? _cache;

  @override
  Future<List<DriverEntity>> getDrivers() async {
    _cache ??= await _remote.fetchDrivers();
    return _cache!;
  }

  @override
  Future<DriverEntity?> findByName(String name) async {
    final drivers = await getDrivers();
    for (final driver in drivers) {
      if (driver.name == name) return driver;
    }
    return null;
  }

  @override
  Future<DriverEntity?> findById(String id) async {
    final drivers = await getDrivers();
    for (final driver in drivers) {
      if (driver.id == id) return driver;
    }
    return null;
  }

  @override
  Future<List<DriverReviewEntity>> getReviews(String driverId) async {
    return _reviewRemote.fetchReviews(driverId);
  }
}
