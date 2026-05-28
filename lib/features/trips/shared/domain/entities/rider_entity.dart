class RiderEntity {
  const RiderEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final double rating;
  final String? avatarUrl;

  factory RiderEntity.fromJson(Map<String, dynamic> json) {
    return RiderEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      rating: (json['rating'] as num).toDouble(),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
