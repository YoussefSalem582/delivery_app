import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_theme.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key, this.filteredUnread = false});

  final bool filteredUnread;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = NotificationTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.emptyIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                filteredUnread
                    ? Icons.mark_email_read_outlined
                    : Icons.notifications_none_outlined,
                size: 64,
                color: theme.emptyIconTint,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              filteredUnread
                  ? 'notifications_empty_unread'.tr()
                  : 'no_notifications'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: theme.titleColor(isRead: false),
                  ),
              textAlign: TextAlign.center,
            ),
            if (!filteredUnread) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'notifications_empty_subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
