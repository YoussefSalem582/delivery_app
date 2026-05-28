import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_theme.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.filter,
    required this.unreadCount,
  });

  final NotificationFilter filter;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = NotificationTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.filterBarBackground,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: theme.filterBarBorderAlpha,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: SegmentedButton<NotificationFilter>(
          segments: [
            ButtonSegment(
              value: NotificationFilter.all,
              label: Text('notifications_filter_all'.tr()),
            ),
            ButtonSegment(
              value: NotificationFilter.unread,
              label: Text(
                unreadCount > 0
                    ? '${'notifications_filter_unread'.tr()} ($unreadCount)'
                    : 'notifications_filter_unread'.tr(),
              ),
            ),
          ],
          selected: {filter},
          onSelectionChanged: (selected) {
            context.read<NotificationBloc>().add(
                  NotificationFilterChanged(selected.first),
                );
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: scheme.surfaceContainer,
            selectedBackgroundColor: scheme.primary,
            foregroundColor: scheme.onSurfaceVariant,
            selectedForegroundColor: scheme.onPrimary,
            side: BorderSide(
              color: scheme.outlineVariant.withValues(
                alpha: theme.isDark ? 0.45 : 0.5,
              ),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}
