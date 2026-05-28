import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/driver/home/presentation/pages/driver_home_page.dart';
import 'package:delivery_app/features/driver/jobs/presentation/bloc/driver_jobs_bloc.dart';
import 'package:delivery_app/features/driver/jobs/presentation/pages/driver_jobs_page.dart';
import 'package:delivery_app/features/driver/profile/presentation/pages/driver_profile_tab_page.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell for authenticated driver tabs.
class DriverMainShellPage extends StatefulWidget {
  const DriverMainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<DriverMainShellPage> createState() => _DriverMainShellPageState();
}

class _DriverMainShellPageState extends State<DriverMainShellPage> {
  @override
  void initState() {
    super.initState();
    sl<NotificationBloc>().add(const NotificationLoadRequested());
  }

  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    if (index == 1) {
      final authState = sl<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        sl<DriverJobsBloc>().add(
          DriverJobsCacheSyncRequested(driverId: authState.user.id),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, notificationState) {
        final unreadCount = notificationState is NotificationLoaded
            ? notificationState.unreadCount
            : 0;

        return Scaffold(
          body: widget.navigationShell,
          bottomNavigationBar: AppBottomNavBar(
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _onTabSelected,
            destinations: [
              AppNavDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'driver_home_tab'.tr(),
                badgeCount: unreadCount,
              ),
              AppNavDestination(
                icon: Icons.work_outline,
                selectedIcon: Icons.work,
                label: 'driver_jobs_tab'.tr(),
              ),
              AppNavDestination(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'profile_tab'.tr(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DriverHomeTabPage extends StatelessWidget {
  const DriverHomeTabPage({super.key});

  @override
  Widget build(BuildContext context) => const DriverHomePage();
}

class DriverJobsTabPage extends StatelessWidget {
  const DriverJobsTabPage({super.key});

  @override
  Widget build(BuildContext context) => const DriverJobsPage();
}

class DriverProfileTabShellPage extends StatelessWidget {
  const DriverProfileTabShellPage({super.key});

  @override
  Widget build(BuildContext context) => const DriverProfileTabPage();
}
