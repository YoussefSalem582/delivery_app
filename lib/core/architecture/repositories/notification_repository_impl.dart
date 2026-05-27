import 'package:delivery_app/core/architecture/datasources/notification_local_datasource.dart';
import 'package:delivery_app/core/architecture/entities/notification_entity.dart';
import 'package:delivery_app/core/architecture/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._local);

  final NotificationLocalDataSource _local;

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return _local.getAll();
  }

  @override
  Future<void> addNotification(NotificationEntity notification) async {
    await _local.save(notification);
  }

  @override
  Future<void> markAsRead(String id) async {
    final existing = _local.getAll().firstWhere(
          (n) => n.id == id,
          orElse: () => NotificationEntity(
            id: id,
            title: '',
            body: '',
            createdAt: DateTime.now(),
          ),
        );
    if (existing.title.isNotEmpty) {
      await _local.save(existing.copyWith(isRead: true));
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final all = _local.getAll();
    for (final n in all) {
      await _local.save(n.copyWith(isRead: true));
    }
  }

  @override
  int get unreadCount => _local.unreadCount;
}
