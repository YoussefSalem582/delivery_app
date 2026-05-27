class DriverEntity {
  const DriverEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.vehicle,
    required this.lat,
    required this.lng,
  });

  final String id;
  final String name;
  final String phone;
  final double rating;
  final String vehicle;
  final double lat;
  final double lng;

  factory DriverEntity.fromJson(Map<String, dynamic> json) {
    return DriverEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      rating: (json['rating'] as num).toDouble(),
      vehicle: json['vehicle'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
