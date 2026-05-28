import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_select/presentation/pages/auth_choice_page.dart';
import '../../features/auth/forgot_password/presentation/pages/forgot_password_page.dart';
import '../../features/auth/login/presentation/pages/login_page.dart';
import '../../features/auth/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/register/presentation/pages/register_page.dart';
import '../../features/auth/shared/presentation/bloc/auth_bloc.dart';
import '../../features/auth/shared/presentation/widgets/auth/auth_form_bloc_listener.dart';
import '../../features/auth/splash/presentation/pages/splash_page.dart';
import '../../features/driver/active_trip/presentation/pages/driver_active_trip_page.dart';
import '../../features/driver/main_shell/presentation/pages/driver_main_shell_page.dart';
import '../../features/driver/onboarding/presentation/pages/driver_onboarding_page.dart';
import '../../features/driver/shared/domain/entities/app_mode.dart';
import '../../features/driver/shared/presentation/cubit/app_mode_cubit.dart';
import '../../features/home/main_shell/presentation/pages/main_shell_page.dart';
import '../../features/trips/tracking/presentation/pages/tracking_page.dart';
import '../../features/trips/trip_detail/presentation/pages/trip_detail_page.dart';
import '../../features/trips/driver_chat/presentation/pages/driver_chat_page.dart';
import '../../features/trips/driver_call/presentation/pages/driver_call_page.dart';
import '../../features/trips/driver_profile/presentation/pages/driver_profile_page.dart';
import '../../injection_container.dart';
import '../environment/env_config.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _authShellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: EnvConfig.enableLogging,
    refreshListenable: _GoRouterAppRefresh(
      authStream: sl<AuthBloc>().stream,
      modeStream: sl<AppModeCubit>().stream,
    ),
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;
      final appMode = sl<AppModeCubit>().state.mode;
      final isAuthenticated = authState is AuthAuthenticated;
      final isTransient = authState is AuthLoading || authState is AuthInitial;
      final isDriverRegistered = authState is AuthAuthenticated
          ? authState.user.isDriverRegistered
          : false;

      const publicPaths = {
        '/',
        '/onboarding',
        '/auth-select',
        '/login',
        '/register',
        '/forgot-password',
      };
      final location = state.matchedLocation;
      final isPublicRoute = publicPaths.contains(location);
      final isDriverRoute = location.startsWith('/driver');

      if (isTransient) return null;

      if (!isAuthenticated && !isPublicRoute) return '/';

      if (isAuthenticated && isPublicRoute) {
        return appMode.isDriver && isDriverRegistered
            ? '/driver/home'
            : '/home';
      }

      if (isAuthenticated && isDriverRoute && !isDriverRegistered) {
        return '/driver/onboarding';
      }

      if (isAuthenticated &&
          isDriverRoute &&
          location == '/driver/onboarding' &&
          isDriverRegistered) {
        return '/driver/home';
      }

      if (isAuthenticated &&
          !isDriverRoute &&
          !isPublicRoute &&
          appMode.isDriver &&
          isDriverRegistered &&
          !location.startsWith('/trips/')) {
        return '/driver/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        pageBuilder: (context, state) =>
            _heroPage(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        pageBuilder: (context, state) =>
            _heroPage(state: state, child: const OnboardingPage()),
      ),
      GoRoute(
        path: '/auth-select',
        name: RouteNames.authSelect,
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const AuthChoicePage()),
      ),
      ShellRoute(
        navigatorKey: _authShellNavigatorKey,
        builder: (context, state, child) =>
            AuthFormBlocListener(child: child),
        routes: [
          GoRoute(
            path: '/login',
            name: RouteNames.login,
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const LoginPage()),
          ),
          GoRoute(
            path: '/register',
            name: RouteNames.register,
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const RegisterPage()),
          ),
          GoRoute(
            path: '/forgot-password',
            name: RouteNames.forgotPassword,
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const ForgotPasswordPage()),
          ),
        ],
      ),
      GoRoute(
        path: '/driver/onboarding',
        name: RouteNames.driverOnboarding,
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const DriverOnboardingPage(),
        ),
      ),
      GoRoute(
        path: '/driver/trips/:tripId/active',
        name: RouteNames.driverActiveTrip,
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return _fadePage(
            state: state,
            child: DriverActiveTripPage(tripId: tripId),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const HomeTabPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                name: RouteNames.trips,
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const TripsTabPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                name: RouteNames.notifications,
                pageBuilder: (context, state) => _fadePage(
                  state: state,
                  child: const NotificationsTabPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const ProfileTabPage()),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            DriverMainShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/driver/home',
                name: RouteNames.driverHome,
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const DriverHomeTabPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/driver/jobs',
                name: RouteNames.driverJobs,
                pageBuilder: (context, state) =>
                    _fadePage(state: state, child: const DriverJobsTabPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/driver/profile',
                name: RouteNames.driverShellProfile,
                pageBuilder: (context, state) => _fadePage(
                  state: state,
                  child: const DriverProfileTabShellPage(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/trips/:tripId',
        name: RouteNames.tripDetail,
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return _fadePage(
            state: state,
            child: TripDetailPage(tripId: tripId),
          );
        },
      ),
      GoRoute(
        path: '/trips/:tripId/track',
        name: RouteNames.tracking,
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return _fadePage(
            state: state,
            child: TrackingPage(tripId: tripId),
          );
        },
      ),
      GoRoute(
        path: '/trips/:tripId/chat',
        name: RouteNames.driverChat,
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return _fadePage(
            state: state,
            child: DriverChatPage(tripId: tripId),
          );
        },
      ),
      GoRoute(
        path: '/trips/:tripId/call',
        name: RouteNames.driverCall,
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return _fadePage(
            state: state,
            child: DriverCallPage(tripId: tripId),
          );
        },
      ),
      GoRoute(
        path: '/trips/:tripId/driver',
        name: RouteNames.driverProfile,
        pageBuilder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          return _fadePage(
            state: state,
            child: DriverProfilePage(tripId: tripId),
          );
        },
      ),
    ],
  );

  static CustomTransitionPage<void> _fadePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Page<void> _heroPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return MaterialPage<void>(
      key: state.pageKey,
      child: child,
    );
  }
}

class _GoRouterAppRefresh extends ChangeNotifier {
  _GoRouterAppRefresh({
    required Stream<AuthState> authStream,
    required Stream<AppModeState> modeStream,
  }) {
    _authSub = authStream.listen((_) => notifyListeners());
    _modeSub = modeStream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _authSub;
  late final StreamSubscription<AppModeState> _modeSub;

  @override
  void dispose() {
    _authSub.cancel();
    _modeSub.cancel();
    super.dispose();
  }
}
