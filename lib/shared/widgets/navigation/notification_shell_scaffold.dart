import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Bottom-nav shell with notification unread badge — shared by passenger and driver modes.
class NotificationShellScaffold extends StatelessWidget {
  const NotificationShellScaffold({
    super.key,
    required this.navigationShell,
    required this.destinations,
    required this.onTabSelected,
    this.notificationBadgeTabIndex,
  });

  final StatefulNavigationShell navigationShell;
  final List<AppNavDestination> destinations;
  final ValueChanged<int> onTabSelected;

  /// Tab index that shows the global unread notification count (e.g. notifications tab or driver home).
  final int? notificationBadgeTabIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, notificationState) {
        final unreadCount = notificationState is NotificationLoaded
            ? notificationState.unreadCount
            : 0;

        final resolvedDestinations = destinations.asMap().entries.map((entry) {
          final destination = entry.value;
          if (entry.key != notificationBadgeTabIndex) {
            return destination;
          }
          return AppNavDestination(
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
            label: destination.label,
            badgeCount: unreadCount,
          );
        }).toList();

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: AppBottomNavBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: onTabSelected,
            destinations: resolvedDestinations,
          ),
        );
      },
    );
  }
}
