// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AuthChoicePage]
class AuthChoiceRoute extends PageRouteInfo<void> {
  const AuthChoiceRoute({List<PageRouteInfo>? children})
    : super(AuthChoiceRoute.name, initialChildren: children);

  static const String name = 'AuthChoiceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthChoicePage();
    },
  );
}

/// generated route for
/// [AuthCredentialShellPage]
class AuthCredentialShellRoute extends PageRouteInfo<void> {
  const AuthCredentialShellRoute({List<PageRouteInfo>? children})
    : super(AuthCredentialShellRoute.name, initialChildren: children);

  static const String name = 'AuthCredentialShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthCredentialShellPage();
    },
  );
}

/// generated route for
/// [HomeMapPage]
class HomeMapRoute extends PageRouteInfo<void> {
  const HomeMapRoute({List<PageRouteInfo>? children})
    : super(HomeMapRoute.name, initialChildren: children);

  static const String name = 'HomeMapRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeMapPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MainShellPage]
class MainShellRoute extends PageRouteInfo<void> {
  const MainShellRoute({List<PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainShellPage();
    },
  );
}

/// generated route for
/// [NotificationsPage]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationsPage();
    },
  );
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashPage();
    },
  );
}

/// generated route for
/// [TrackingPage]
class TrackingRoute extends PageRouteInfo<TrackingRouteArgs> {
  TrackingRoute({
    Key? key,
    required String tripId,
    List<PageRouteInfo>? children,
  }) : super(
         TrackingRoute.name,
         args: TrackingRouteArgs(key: key, tripId: tripId),
         rawPathParams: {'tripId': tripId},
         initialChildren: children,
       );

  static const String name = 'TrackingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TrackingRouteArgs>(
        orElse: () => TrackingRouteArgs(tripId: pathParams.getString('tripId')),
      );
      return TrackingPage(key: args.key, tripId: args.tripId);
    },
  );
}

class TrackingRouteArgs {
  const TrackingRouteArgs({this.key, required this.tripId});

  final Key? key;

  final String tripId;

  @override
  String toString() {
    return 'TrackingRouteArgs{key: $key, tripId: $tripId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TrackingRouteArgs) return false;
    return key == other.key && tripId == other.tripId;
  }

  @override
  int get hashCode => key.hashCode ^ tripId.hashCode;
}

/// generated route for
/// [TripDetailPage]
class TripDetailRoute extends PageRouteInfo<TripDetailRouteArgs> {
  TripDetailRoute({
    Key? key,
    required String tripId,
    List<PageRouteInfo>? children,
  }) : super(
         TripDetailRoute.name,
         args: TripDetailRouteArgs(key: key, tripId: tripId),
         rawPathParams: {'tripId': tripId},
         initialChildren: children,
       );

  static const String name = 'TripDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<TripDetailRouteArgs>(
        orElse: () =>
            TripDetailRouteArgs(tripId: pathParams.getString('tripId')),
      );
      return TripDetailPage(key: args.key, tripId: args.tripId);
    },
  );
}

class TripDetailRouteArgs {
  const TripDetailRouteArgs({this.key, required this.tripId});

  final Key? key;

  final String tripId;

  @override
  String toString() {
    return 'TripDetailRouteArgs{key: $key, tripId: $tripId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TripDetailRouteArgs) return false;
    return key == other.key && tripId == other.tripId;
  }

  @override
  int get hashCode => key.hashCode ^ tripId.hashCode;
}

/// generated route for
/// [TripListPage]
class TripListRoute extends PageRouteInfo<void> {
  const TripListRoute({List<PageRouteInfo>? children})
    : super(TripListRoute.name, initialChildren: children);

  static const String name = 'TripListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TripListPage();
    },
  );
}
