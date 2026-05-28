import 'package:delivery_app/features/trips/shared/data/datasources/rider_remote_datasource.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/rider_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/rider_repository.dart';

class RiderRepositoryImpl implements RiderRepository {
  RiderRepositoryImpl(this._remote);

  final RiderRemoteDataSource _remote;
  List<RiderEntity>? _cache;

  @override
  Future<List<RiderEntity>> getRiders() async {
    _cache ??= await _remote.fetchRiders();
    return _cache!;
  }

  @override
  Future<RiderEntity?> findById(String id) async {
    final riders = await getRiders();
    for (final rider in riders) {
      if (rider.id == id) return rider;
    }
    return null;
  }
}
