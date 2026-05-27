# RideFlow — Flutter Ride-Hailing / Delivery App Template

> **Scalable Uber-like MVP template** — Clean Architecture + BLoC, offline-first Hive cache with reconnect + background sync, live OpenStreetMap tracking via flutter_map, FCM push alerts, bilingual EN/AR with RTL, dark/light themes, responsive tablet layouts, and Talker-observable demo flows. Production-oriented structure ready to swap mock API for a real backend.

## Features

- **Clean Architecture** — `data` / `domain` (entities + repos) / `presentation` (BLoC + UI)
- **Offline-first** — Hive cache for trips, orders, user, notifications; pending sync queue
- **Dual sync** — `connectivity_plus` reconnect sync + `workmanager` periodic background task
- **Maps & tracking** — flutter_map (OpenStreetMap tiles), geolocator live position, simulated driver polyline animation
- **Push notifications** — Firebase Cloud Messaging + simulated fallback for demo without Firebase
- **Themes & i18n** — Dark/light mode, English/Arabic with RTL via `easy_localization`
- **Observability** — Talker logs for Dio, BLoC, and in-app debug console (long-press profile avatar)
- **Navigation** — AutoRoute with tab shell + deep links to trip detail/tracking

## Screens

| Screen | Description |
|--------|-------------|
| Splash | Lottie loader, auth check |
| Login | Mock login (any credentials) |
| Home | Live map + request ride FAB |
| Trips | History list, pull-to-refresh, offline badge |
| Trip Detail | Status timeline, driver info, track CTA |
| Tracking | Real-time map with polyline + ETA card |
| Profile | Wallet, orders, theme/locale settings |
| Notifications | In-app alerts from FCM/simulated events |

## Prerequisites

- Flutter 3.16+ (tested on 3.44)
- Android Studio / Xcode for device builds
- Internet access for map tiles (OpenStreetMap)
- Firebase project (optional — app runs with simulated notifications)

## Setup

### 1. Install dependencies

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 2. Maps (flutter_map)

Maps use **OpenStreetMap** tiles via `flutter_map` — no API key required for the demo.

Tile URL is configured in `lib/core/utils/map_config.dart`. For production, consider a tile provider with usage terms that fit your app (Mapbox, Stadia, self-hosted tiles, etc.).

### 3. Firebase (optional)

1. Create a Firebase project and add Android + iOS apps.
2. Download `google-services.json` → `android/app/`
3. Download `GoogleService-Info.plist` → `ios/Runner/`
4. Run `flutterfire configure` or add Firebase Gradle plugin manually.

Without Firebase, the app still runs — trip notifications are simulated via `FcmService.simulateTripNotification`.

### 4. Run

```bash
flutter run
```

## Demo flow

1. **Login** — use any email/password (e.g. `demo@delivery.app` / `password`)
2. **Home** — tap **Request Ride**, confirm pickup/dropoff
3. **Tracking** — watch driver marker animate along polyline
4. **Trips** — see cached trip list; pull to refresh
5. **Offline** — enable airplane mode, request a ride (queued locally), disable airplane mode, tap sync icon — Talker logs sync
6. **Notifications** — request ride or simulate driver arrived on trip detail
7. **Profile** — toggle dark mode, switch to Arabic (RTL), long-press avatar for Talker console
8. **Complete trip** — from trip detail, tap Complete Trip

## Architecture

```
lib/
├── core/architecture/   # entities, repos, datasources
├── core/network/        # Dio mock API, FCM
├── core/sync/           # SyncService + WorkManager
├── core/theme/          # AppTheme, ThemeCubit, LocaleCubit
├── features/            # splash, auth, home, trips, profile, notifications
├── routes/              # AutoRoute config
├── injection_container.dart
└── main.dart
```

## Testing

```bash
flutter test
```

Includes `bloc_test` coverage for `TripListBloc`, `RequestRideBloc`, and tracking route interpolation.

## Freelance pitch

This template demonstrates production patterns clients expect from ride-hailing / delivery MVPs:

- Swap mock JSON API for real REST/GraphQL backend
- Extend Hive sync for conflict resolution
- Plug in Stripe/wallet payments
- Scale BLoCs per feature team

## License

MIT — use freely in portfolios and client demos.
