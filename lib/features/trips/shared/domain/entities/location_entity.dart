import 'package:hive/hive.dart';

class LocationEntity extends HiveObject {
  LocationEntity({
    required this.lat,
    required this.lng,
    this.address,
  });

  final double lat;
  final double lng;
  final String? address;

  LocationEntity copyWith({double? lat, double? lng, String? address}) {
    return LocationEntity(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'address': address,
      };

  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    return LocationEntity(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String?,
    );
  }
}
