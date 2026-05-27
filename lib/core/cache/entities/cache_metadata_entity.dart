import 'package:hive/hive.dart';

class CacheMetadataEntity extends HiveObject {
  CacheMetadataEntity({
    required this.key,
    required this.lastFetchedAt,
  });

  @override
  final String key;
  final DateTime lastFetchedAt;
}
