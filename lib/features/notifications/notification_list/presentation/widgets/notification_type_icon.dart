import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_theme.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';
import 'package:flutter/material.dart';

class NotificationTypeIcon extends StatelessWidget {
  const NotificationTypeIcon({
    super.key,
    required this.type,
    required this.isRead,
  });

  final NotificationType type;
  final bool isRead;

  IconData get _iconData => switch (type) {
        NotificationType.driverOnTheWay ||
        NotificationType.driverArrived =>
          Icons.local_taxi,
        NotificationType.tripAccepted ||
        NotificationType.tripUpdate ||
        NotificationType.tripCompleted =>
          Icons.directions_car,
        NotificationType.promo => Icons.local_offer_outlined,
        NotificationType.general => Icons.notifications_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = NotificationTheme.of(context);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.iconBackground(isRead: isRead),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconData,
        size: 20,
        color: theme.iconForeground(isRead: isRead),
      ),
    );
  }
}
