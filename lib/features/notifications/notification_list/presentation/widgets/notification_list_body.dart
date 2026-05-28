import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_grouping.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_theme.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/widgets/notification_empty_state.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/widgets/notification_filter_bar.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/widgets/notification_tile.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationListBody extends StatelessWidget {
  const NotificationListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: 5,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, _) => const SkeletonListTile(),
            ),
          );
        }
        if (state is NotificationError) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<NotificationBloc>().add(
                  const NotificationLoadRequested(),
                ),
          );
        }
        if (state is NotificationLoaded) {
          final items = state.filteredNotifications;
          if (items.isEmpty) {
            return Column(
              children: [
                NotificationFilterBar(
                  filter: state.filter,
                  unreadCount: state.unreadCount,
                ),
                Expanded(
                  child: NotificationEmptyState(
                    filteredUnread: state.filter == NotificationFilter.unread,
                  ),
                ),
              ],
            );
          }

          final groups = groupNotificationsByDate(items);
          var tileIndex = 0;

          return Column(
            children: [
              NotificationFilterBar(
                filter: state.filter,
                unreadCount: state.unreadCount,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<NotificationBloc>().add(
                          const NotificationRefreshRequested(),
                        );
                    final bloc = context.read<NotificationBloc>();
                    await bloc.stream.firstWhere(
                      (s) =>
                          s is NotificationError ||
                          (s is NotificationLoaded && !s.isRefreshing),
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    itemCount: _listItemCount(groups),
                    itemBuilder: (context, index) {
                      final resolved = _resolveListIndex(groups, index);
                      if (resolved.isHeader) {
                        final theme = NotificationTheme.of(context);
                        return Padding(
                          padding: EdgeInsets.only(
                            top: index == 0 ? 0 : AppSpacing.lg,
                            bottom: AppSpacing.sm,
                          ),
                          child: Text(
                            resolved.headerTitle!,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.sectionHeader,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        );
                      }
                      final tile = NotificationTile(
                        item: resolved.item!,
                        animationIndex: tileIndex,
                      );
                      tileIndex++;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: tile,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

int _listItemCount(List<NotificationSectionGroup> groups) {
  var count = 0;
  for (final group in groups) {
    count += 1 + group.items.length;
  }
  return count;
}

class _ResolvedListItem {
  const _ResolvedListItem.header(this.headerTitle)
      : item = null,
        isHeader = true;

  const _ResolvedListItem.tile(this.item)
      : headerTitle = null,
        isHeader = false;

  final String? headerTitle;
  final NotificationEntity? item;
  final bool isHeader;
}

_ResolvedListItem _resolveListIndex(
  List<NotificationSectionGroup> groups,
  int index,
) {
  var cursor = 0;
  for (final group in groups) {
    if (cursor == index) {
      return _ResolvedListItem.header(group.title);
    }
    cursor++;
    for (final item in group.items) {
      if (cursor == index) {
        return _ResolvedListItem.tile(item);
      }
      cursor++;
    }
  }
  throw RangeError.index(index, groups, 'index');
}
