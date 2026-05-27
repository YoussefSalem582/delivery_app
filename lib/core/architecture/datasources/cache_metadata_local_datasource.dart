import 'package:hive/hive.dart';
import 'package:delivery_app/core/architecture/entities/cache_metadata_entity.dart';
import 'package:delivery_app/core/utils/constants.dart';

class CacheKeys {
  CacheKeys._();

  static const trips = 'trips';
  static const orders = 'orders';
  static const profile = 'profile';
}

class CacheMetadataLocalDataSource {
  CacheMetadataLocalDataSource(this._box);

  final Box<CacheMetadataEntity> _box;

  DateTime? getLastFetched(String key) => _box.get(key)?.lastFetchedAt;

  Future<void> markFetched(String key) async {
    await _box.put(
      key,
      CacheMetadataEntity(key: key, lastFetchedAt: DateTime.now()),
    );
  }
}

Future<Box<CacheMetadataEntity>> openCacheMetaBox() async {
  return Hive.openBox<CacheMetadataEntity>(AppConstants.cacheMetaBox);
}
