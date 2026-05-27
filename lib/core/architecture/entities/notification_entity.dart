import 'package:hive/hive.dart';

class NotificationEntity extends HiveObject {
  NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.tripId,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? tripId;
  final bool isRead;

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      tripId: tripId,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'tripId': tripId,
        'isRead': isRead,
      };

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tripId: json['tripId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
