import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:delivery_app/features/home/map_view/presentation/pages/home_map_page.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/trips/trip_list/presentation/bloc/trip_list_bloc.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/pages/notifications_page.dart';
import 'package:delivery_app/features/profile/profile_view/presentation/pages/profile_page.dart';
import 'package:delivery_app/features/trips/trip_list/presentation/pages/trip_list_page.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/widgets/navigation/notification_shell_scaffold.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell for authenticated ride-hailing tabs.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    if (index == 1) {
      sl<TripListBloc>().add(const TripListCacheSyncRequested());
    }
    if (index == 2) {
      sl<NotificationBloc>().add(const NotificationLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationShellScaffold(
      navigationShell: widget.navigationShell,
      notificationBadgeTabIndex: 2,
      onTabSelected: _onTabSelected,
      destinations: [
        AppNavDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'home_tab'.tr(),
        ),
        AppNavDestination(
          icon: Icons.directions_car_outlined,
          selectedIcon: Icons.directions_car,
          label: 'trips_tab'.tr(),
        ),
        AppNavDestination(
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          label: 'notifications_tab'.tr(),
        ),
        AppNavDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: 'profile_tab'.tr(),
        ),
      ],
    );
  }
}

/// Tab roots used by [StatefulShellRoute].
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) => const HomeMapPage();
}

class TripsTabPage extends StatelessWidget {
  const TripsTabPage({super.key});

  @override
  Widget build(BuildContext context) => const TripListPage();
}

class NotificationsTabPage extends StatelessWidget {
  const NotificationsTabPage({super.key});

  @override
  Widget build(BuildContext context) => const NotificationsPage();
}

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) => const ProfilePage();
}
