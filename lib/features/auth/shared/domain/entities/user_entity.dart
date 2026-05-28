import 'package:hive/hive.dart';

import 'package:delivery_app/features/driver/shared/domain/entities/driver_profile_entity.dart';

class UserEntity extends HiveObject {
  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.walletBalance,
    this.avatarUrl,
    this.isLoggedIn = false,
    this.isDriverRegistered = false,
    this.driverProfile,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final double walletBalance;
  final String? avatarUrl;
  final bool isLoggedIn;
  final bool isDriverRegistered;
  final DriverProfileEntity? driverProfile;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? walletBalance,
    String? avatarUrl,
    bool? isLoggedIn,
    bool? isDriverRegistered,
    DriverProfileEntity? driverProfile,
    bool clearDriverProfile = false,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      walletBalance: walletBalance ?? this.walletBalance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isDriverRegistered: isDriverRegistered ?? this.isDriverRegistered,
      driverProfile:
          clearDriverProfile ? null : (driverProfile ?? this.driverProfile),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'walletBalance': walletBalance,
        'avatarUrl': avatarUrl,
        'isDriverRegistered': isDriverRegistered,
        if (driverProfile != null) 'driverProfile': driverProfile!.toJson(),
      };

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      walletBalance: (json['walletBalance'] as num).toDouble(),
      avatarUrl: json['avatarUrl'] as String?,
      isDriverRegistered: json['isDriverRegistered'] as bool? ?? false,
      driverProfile: json['driverProfile'] != null
          ? DriverProfileEntity.fromJson(
              json['driverProfile'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
