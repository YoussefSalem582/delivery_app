import 'package:hive/hive.dart';
import 'package:delivery_app/core/architecture/entities/route_cache_entity.dart';
import 'package:delivery_app/core/utils/constants.dart';

class RouteCacheLocalDataSource {
  RouteCacheLocalDataSource(this._box);

  final Box<RouteCacheEntity> _box;

  RouteCacheEntity? get(String cacheKey) => _box.get(cacheKey);

  Future<void> put(RouteCacheEntity entry) async {
    await _box.put(entry.cacheKey, entry);
    await _evictIfNeeded();
  }

  Future<void> _evictIfNeeded() async {
    if (_box.length <= AppConstants.routeCacheMaxEntries) return;

    final sorted = _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final toRemove = sorted.length - AppConstants.routeCacheMaxEntries;
    for (var i = 0; i < toRemove; i++) {
      await _box.delete(sorted[i].cacheKey);
    }
  }
}

Future<Box<RouteCacheEntity>> openRouteCacheBox() async {
  return Hive.openBox<RouteCacheEntity>(AppConstants.routeCacheBox);
}
