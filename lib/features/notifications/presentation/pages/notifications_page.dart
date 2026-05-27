import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/notification_entity.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_trip_widgets.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

@RoutePage()
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('notifications_title'.tr()),
          leading: IconButton(
            icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onPressed: () {},
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.unreadCount > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: NoktaSpacing.md),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${state.unreadCount}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox(width: NoktaSpacing.md);
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return Skeletonizer(
                enabled: true,
                child: ListView.separated(
                  padding: const EdgeInsets.all(NoktaSpacing.md),
                  itemCount: 5,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: NoktaSpacing.sm),
                  itemBuilder: (_, __) => const SkeletonListTile(),
                ),
              );
            }
            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: NoktaSpacing.md),
                      Text(
                        'no_notifications'.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(NoktaSpacing.md),
                itemCount: state.notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: NoktaSpacing.sm),
                itemBuilder: (context, index) {
                  final item = state.notifications[index];
                  return _NotificationCard(item: item);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final NotificationEntity item;

  IconData get _icon {
    if (item.title.contains('driver')) return Icons.local_taxi;
    if (item.title.contains('trip')) return Icons.directions_car;
    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: NoktaSpacing.md),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
        ),
        child: Text(
          'mark_read'.tr(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onPrimary,
              ),
        ),
      ),
      onDismissed: (_) {
        context.read<NotificationBloc>().add(
              NotificationMarkReadRequested(item.id),
            );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          onTap: () {
            context.read<NotificationBloc>().add(
                  NotificationMarkReadRequested(item.id),
                );
            if (item.tripId != null) {
              context.router.push(TripDetailRoute(tripId: item.tripId!));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(NoktaSpacing.md),
            decoration: BoxDecoration(
              color: item.isRead
                  ? scheme.surfaceContainerLow
                  : scheme.primaryContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
              border: Border.all(
                color: item.isRead
                    ? scheme.outlineVariant
                    : scheme.primaryContainer.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.isRead
                        ? scheme.surfaceContainer
                        : scheme.primaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon,
                    size: 20,
                    color: item.isRead ? scheme.onSurfaceVariant : scheme.primary,
                  ),
                ),
                const SizedBox(width: NoktaSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title.tr(),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight:
                                        item.isRead ? FontWeight.w600 : FontWeight.w700,
                                  ),
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: NoktaSpacing.sm),
                      Text(
                        formatTripDate(item.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
