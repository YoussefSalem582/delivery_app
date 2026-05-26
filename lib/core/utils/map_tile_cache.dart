import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:path_provider/path_provider.dart';

class MapTileCache {
  MapTileCache._();

  static CachedTileProvider? tileProvider;

  static Future<void> init() async {
    if (tileProvider != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final store = FileCacheStore('${dir.path}/map_tiles');
    tileProvider = CachedTileProvider(
      store: store,
      maxStale: const Duration(days: 30),
    );
  }
}
