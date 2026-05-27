import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/utils/responsive.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<NotificationBloc>()..add(const NotificationLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('notifications_title'.tr()),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.unreadCount > 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Badge(label: Text('${state.unreadCount}')),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return LoadingView(message: 'loading');
            }
            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return Center(child: Text('no_notifications'.tr()));
              }
              return ListView.separated(
                padding: Responsive.pagePadding(context),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = state.notifications[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Text('mark_read'.tr()),
                    ),
                    onDismissed: (_) {
                      context.read<NotificationBloc>().add(
                            NotificationMarkReadRequested(item.id),
                          );
                    },
                    child: Card(
                      color: item.isRead
                          ? null
                          : Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.3),
                      child: ListTile(
                        leading: Icon(
                          item.isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                        ),
                        title: Text(item.title.tr()),
                        subtitle: Text(item.body.tr()),
                        trailing: Text(
                          DateFormat.Hm().format(item.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onTap: () {
                          context.read<NotificationBloc>().add(
                                NotificationMarkReadRequested(item.id),
                              );
                          if (item.tripId != null) {
                            context.router
                                .push(TripDetailRoute(tripId: item.tripId!));
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
