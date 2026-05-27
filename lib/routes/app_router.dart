import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/widgets/nokta_bottom_nav_bar.dart';
import 'package:delivery_app/features/auth/presentation/pages/auth_choice_page.dart';
import 'package:delivery_app/features/auth/presentation/pages/auth_credential_shell_page.dart';
import 'package:delivery_app/features/auth/presentation/pages/login_page.dart';
import 'package:delivery_app/features/auth/presentation/pages/onboarding_page.dart';
import 'package:delivery_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:delivery_app/features/auth/presentation/pages/register_page.dart';
import 'package:delivery_app/features/home/presentation/pages/home_map_page.dart';
import 'package:delivery_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:delivery_app/features/profile/presentation/pages/profile_page.dart';
import 'package:delivery_app/features/splash/presentation/pages/splash_page.dart';
import 'package:delivery_app/features/trips/presentation/pages/tracking_page.dart';
import 'package:delivery_app/features/trips/presentation/pages/trip_detail_page.dart';
import 'package:delivery_app/features/trips/presentation/pages/trip_list_page.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: AuthChoiceRoute.page),
        AutoRoute(
          page: AuthCredentialShellRoute.page,
          children: [
            AutoRoute(page: LoginRoute.page, initial: true),
            AutoRoute(page: RegisterRoute.page),
            AutoRoute(page: ForgotPasswordRoute.page),
          ],
        ),
        AutoRoute(
          page: MainShellRoute.page,
          children: [
            AutoRoute(page: HomeMapRoute.page),
            AutoRoute(page: TripListRoute.page),
            AutoRoute(page: NotificationsRoute.page),
            AutoRoute(page: ProfileRoute.page),
          ],
        ),
        AutoRoute(page: TripDetailRoute.page, path: '/trips/:tripId'),
        AutoRoute(page: TrackingRoute.page, path: '/trips/:tripId/track'),
      ];
}

@RoutePage()
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeMapRoute(),
        TripListRoute(),
        NotificationsRoute(),
        ProfileRoute(),
      ],
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: NoktaBottomNavBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: (index) {
              tabsRouter.setActiveIndex(index);
              if (index == 2) {
                sl<NotificationBloc>().add(const NotificationLoadRequested());
              }
            },
            destinations: [
              NoktaNavDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'home_tab'.tr(),
              ),
              NoktaNavDestination(
                icon: Icons.directions_car_outlined,
                selectedIcon: Icons.directions_car,
                label: 'trips_tab'.tr(),
              ),
              NoktaNavDestination(
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications,
                label: 'notifications_tab'.tr(),
              ),
              NoktaNavDestination(
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
