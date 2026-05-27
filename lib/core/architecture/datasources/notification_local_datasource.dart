import 'package:hive/hive.dart';
import 'package:delivery_app/core/architecture/entities/notification_entity.dart';
import 'package:delivery_app/core/utils/constants.dart';

class NotificationLocalDataSource {
  NotificationLocalDataSource(this._box);

  final Box<NotificationEntity> _box;

  List<NotificationEntity> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> save(NotificationEntity notification) async {
    await _box.put(notification.id, notification);
  }

  Future<void> saveAll(List<NotificationEntity> notifications) async {
    for (final n in notifications) {
      await _box.put(n.id, n);
    }
  }

  int get unreadCount => _box.values.where((n) => !n.isRead).length;
}

Future<Box<NotificationEntity>> openNotificationsBox() async {
  return Hive.openBox<NotificationEntity>(AppConstants.notificationsBox);
}
