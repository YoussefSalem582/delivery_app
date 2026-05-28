import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/utils/notification_theme.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/widgets/notification_list_body.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_app_bar_logo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = NotificationTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.appBarTitle,
        automaticallyImplyLeading: false,
        leading: const ShellAppBarLogo(),
        title: Text(
          'notifications_title'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme.appBarTitle,
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () => context.read<NotificationBloc>().add(
                        const NotificationMarkAllReadRequested(),
                      ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.appBarAction,
                  ),
                  child: Text('notifications_mark_all_read'.tr()),
                );
              }
              return const SizedBox(width: AppSpacing.md);
            },
          ),
        ],
      ),
      body: const NotificationListBody(),
    );
  }
}
