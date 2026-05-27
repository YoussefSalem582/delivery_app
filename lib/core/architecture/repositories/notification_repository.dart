import 'package:delivery_app/core/architecture/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> addNotification(NotificationEntity notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  int get unreadCount;
}
