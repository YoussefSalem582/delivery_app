class DriverProfileEntity {
  const DriverProfileEntity({
    required this.phone,
    required this.vehicleType,
    required this.vehicleMakeModel,
    required this.licensePlate,
    required this.registeredAt,
    required this.termsAccepted,
  });

  final String phone;
  final String vehicleType;
  final String vehicleMakeModel;
  final String licensePlate;
  final DateTime registeredAt;
  final bool termsAccepted;

  DriverProfileEntity copyWith({
    String? phone,
    String? vehicleType,
    String? vehicleMakeModel,
    String? licensePlate,
    DateTime? registeredAt,
    bool? termsAccepted,
  }) {
    return DriverProfileEntity(
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleMakeModel: vehicleMakeModel ?? this.vehicleMakeModel,
      licensePlate: licensePlate ?? this.licensePlate,
      registeredAt: registeredAt ?? this.registeredAt,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'vehicleType': vehicleType,
    'vehicleMakeModel': vehicleMakeModel,
    'licensePlate': licensePlate,
    'registeredAt': registeredAt.toIso8601String(),
    'termsAccepted': termsAccepted,
  };

  factory DriverProfileEntity.fromJson(Map<String, dynamic> json) {
    return DriverProfileEntity(
      phone: json['phone'] as String,
      vehicleType: json['vehicleType'] as String,
      vehicleMakeModel: json['vehicleMakeModel'] as String,
      licensePlate: json['licensePlate'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      termsAccepted: json['termsAccepted'] as bool? ?? true,
    );
  }
}
