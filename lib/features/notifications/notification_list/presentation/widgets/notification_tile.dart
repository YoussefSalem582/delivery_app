import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_theme.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/widgets/notification_type_icon.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_entity.dart';
import 'package:delivery_app/features/trips/shared/presentation/widgets/trip_widgets.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.item,
    this.animationIndex = 0,
  });

  final NotificationEntity item;
  final int animationIndex;

  @override
  Widget build(BuildContext context) {
    final theme = NotificationTheme.of(context);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.swipeDeleteBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.swipeDeleteIcon,
        ),
      ),
      confirmDismiss: (_) async {
        context.read<NotificationBloc>().add(
              NotificationDeleteRequested(item.id),
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('notifications_deleted'.tr()),
              action: SnackBarAction(
                label: 'notifications_deleted_undo'.tr(),
                onPressed: () {
                  context.read<NotificationBloc>().add(
                        NotificationRestoreRequested(item),
                      );
                },
              ),
            ),
          );
        }
        return true;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: theme.inkSplash,
          highlightColor: theme.inkSplash,
          onTap: () {
            if (!item.isRead) {
              context.read<NotificationBloc>().add(
                    NotificationMarkReadRequested(item.id),
                  );
            }
            if (item.tripId != null) {
              context.pushNamed(
                RouteNames.tripDetail,
                pathParameters: {'tripId': item.tripId!},
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardBackground(isRead: item.isRead),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: theme.cardBorder(isRead: item.isRead),
              ),
              boxShadow: theme.cardShadow(isRead: item.isRead),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!item.isRead)
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: theme.unreadAccent,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ),
                  Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NotificationTypeIcon(
                          type: item.type,
                          isRead: item.isRead,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      localizeNotificationText(item.title),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: theme.titleColor(
                                              isRead: item.isRead,
                                            ),
                                            fontWeight: item.isRead
                                                ? FontWeight.w600
                                                : FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  if (!item.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(
                                        left: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.unreadIndicator,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                localizeNotificationText(item.body),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: theme.bodyColor,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                formatTripDate(item.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: theme.timestampColor),
                              ),
                            ],
                          ),
                        ),
                        if (item.tripId != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.chevron_right,
                            color: theme.chevronColor,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 220.ms,
          delay: (animationIndex * 40).ms,
        )
        .slideY(begin: 0.04, end: 0, duration: 220.ms);
  }
}
