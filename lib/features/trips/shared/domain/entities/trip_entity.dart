import 'package:hive/hive.dart';

enum TripStatus {
  requested,
  accepted,
  driverArrived,
  inProgress,
  completed,
  cancelled,
}

class TripEntity extends HiveObject {
  TripEntity({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.status,
    this.driverName,
    this.driverPhone,
    this.driverAvatarUrl,
    this.driverRating,
    this.driverVehicle,
    required this.fare,
    required this.createdAt,
    required this.updatedAt,
    this.isPendingSync = false,
  });

  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final TripStatus status;
  final String? driverName;
  final String? driverPhone;
  final String? driverAvatarUrl;
  final double? driverRating;
  final String? driverVehicle;
  final double fare;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPendingSync;

  TripEntity copyWith({
    String? id,
    String? pickupAddress,
    String? dropoffAddress,
    double? pickupLat,
    double? pickupLng,
    double? dropoffLat,
    double? dropoffLng,
    TripStatus? status,
    String? driverName,
    String? driverPhone,
    String? driverAvatarUrl,
    double? driverRating,
    String? driverVehicle,
    double? fare,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPendingSync,
  }) {
    return TripEntity(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverAvatarUrl: driverAvatarUrl ?? this.driverAvatarUrl,
      driverRating: driverRating ?? this.driverRating,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      fare: fare ?? this.fare,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pickupAddress': pickupAddress,
        'dropoffAddress': dropoffAddress,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'dropoffLat': dropoffLat,
        'dropoffLng': dropoffLng,
        'status': status.name,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'driverAvatarUrl': driverAvatarUrl,
        'driverRating': driverRating,
        'driverVehicle': driverVehicle,
        'fare': fare,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TripEntity.fromJson(Map<String, dynamic> json) {
    return TripEntity(
      id: json['id'] as String,
      pickupAddress: json['pickupAddress'] as String,
      dropoffAddress: json['dropoffAddress'] as String,
      pickupLat: (json['pickupLat'] as num).toDouble(),
      pickupLng: (json['pickupLng'] as num).toDouble(),
      dropoffLat: (json['dropoffLat'] as num).toDouble(),
      dropoffLng: (json['dropoffLng'] as num).toDouble(),
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.requested,
      ),
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      driverAvatarUrl: json['driverAvatarUrl'] as String?,
      driverRating: json['driverRating'] != null
          ? (json['driverRating'] as num).toDouble()
          : null,
      driverVehicle: json['driverVehicle'] as String?,
      fare: (json['fare'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
