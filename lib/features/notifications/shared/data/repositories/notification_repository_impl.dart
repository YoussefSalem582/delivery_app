import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:delivery_app/features/notifications/shared/data/datasources/notification_local_datasource.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_entity.dart';
import 'package:delivery_app/features/notifications/shared/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._local);

  final NotificationLocalDataSource _local;
  static bool _seedAttempted = false;

  Future<void> _seedIfEmpty() async {
    if (_seedAttempted || _local.getAll().isNotEmpty) return;
    _seedAttempted = true;
    try {
      final json = await rootBundle.loadString('assets/mock/notifications.json');
      final list = jsonDecode(json) as List<dynamic>;
      final notifications = list
          .map(
            (e) => NotificationEntity.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      await _local.saveAll(notifications);
    } catch (_) {
      // Asset optional; FCM/simulate still populate notifications.
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await _seedIfEmpty();
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
  Future<void> deleteNotification(String id) async {
    await _local.delete(id);
  }

  @override
  int get unreadCount => _local.unreadCount;
}
