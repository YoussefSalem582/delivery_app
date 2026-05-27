import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

class RouteCacheEntity extends HiveObject {
  RouteCacheEntity({
    required this.cacheKey,
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.createdAt,
  });

  final String cacheKey;
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final DateTime createdAt;
}
