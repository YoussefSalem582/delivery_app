import 'package:delivery_app/features/notifications/shared/domain/entities/notification_entity.dart';
import 'package:easy_localization/easy_localization.dart';

enum NotificationDateSection { today, yesterday, earlier }

class NotificationSectionGroup {
  const NotificationSectionGroup({
    required this.section,
    required this.items,
  });

  final NotificationDateSection section;
  final List<NotificationEntity> items;

  String get titleKey => switch (section) {
        NotificationDateSection.today => 'today',
        NotificationDateSection.yesterday => 'yesterday',
        NotificationDateSection.earlier => 'notifications_section_earlier',
      };

  String get title => titleKey.tr();
}

NotificationDateSection notificationDateSection(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) return NotificationDateSection.today;
  if (day == today.subtract(const Duration(days: 1))) {
    return NotificationDateSection.yesterday;
  }
  return NotificationDateSection.earlier;
}

List<NotificationSectionGroup> groupNotificationsByDate(
  List<NotificationEntity> notifications,
) {
  final today = <NotificationEntity>[];
  final yesterday = <NotificationEntity>[];
  final earlier = <NotificationEntity>[];

  for (final item in notifications) {
    switch (notificationDateSection(item.createdAt)) {
      case NotificationDateSection.today:
        today.add(item);
      case NotificationDateSection.yesterday:
        yesterday.add(item);
      case NotificationDateSection.earlier:
        earlier.add(item);
    }
  }

  final groups = <NotificationSectionGroup>[];
  if (today.isNotEmpty) {
    groups.add(
      NotificationSectionGroup(
        section: NotificationDateSection.today,
        items: today,
      ),
    );
  }
  if (yesterday.isNotEmpty) {
    groups.add(
      NotificationSectionGroup(
        section: NotificationDateSection.yesterday,
        items: yesterday,
      ),
    );
  }
  if (earlier.isNotEmpty) {
    groups.add(
      NotificationSectionGroup(
        section: NotificationDateSection.earlier,
        items: earlier,
      ),
    );
  }
  return groups;
}
