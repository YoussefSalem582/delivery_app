import 'package:hive/hive.dart';

class UserEntity extends HiveObject {
  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.walletBalance,
    this.avatarUrl,
    this.isLoggedIn = false,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final double walletBalance;
  final String? avatarUrl;
  final bool isLoggedIn;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? walletBalance,
    String? avatarUrl,
    bool? isLoggedIn,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      walletBalance: walletBalance ?? this.walletBalance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'walletBalance': walletBalance,
        'avatarUrl': avatarUrl,
      };

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      walletBalance: (json['walletBalance'] as num).toDouble(),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
