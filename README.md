<p align="center">
  <img src="assets/logo.svg" alt="Nokta logo" width="120" />
</p>

<h1 align="center">Nokta</h1>

<p align="center"><strong>Flutter Ride-Hailing / Delivery App</strong></p>

<p align="center">
  <strong>Version:</strong> <code>1.0.0+1</code> — Scalable Uber-like MVP template
</p>

<p align="center">
  Clean Architecture + BLoC · offline-first Hive cache · live map tracking · EN/AR · dark/light themes
</p>

---

## Features

- **Clean Architecture** — per-feature `shared/` (data + domain) + sub-features (`auth/login/`, `trips/trip_list/`, etc.)
- **Use cases** — BLoCs call use cases returning `Either<Failure, T>` (dartz)
- **Navigation** — GoRouter with `RouteNames`, auth-aware redirects, tab shell via `StatefulShellRoute`
- **Offline-first** — Hive cache for trips, orders, user, notifications, OSRM routes; pending sync queue with deduped status updates
- **Unified caching** — 5-minute TTL metadata, stale-while-revalidate in trip/order lists, profile cache-first load, disk route cache (50-entry LRU)
- **Dual sync** — `NetworkStatus` reconnect sync (trips queue + orders + profile refresh) + `workmanager` stub for background
- **Maps & tracking** — flutter_map (OpenStreetMap tiles), OSRM road-following routes, tile disk cache, animated camera, live location marker, geolocator, driver polyline animation
- **Push notifications** — Firebase Cloud Messaging + simulated fallback for demo without Firebase
- **Themes & i18n** — Dark/light mode, Inter + Cairo typography (locale-aware), English/Arabic with RTL via `easy_localization`
- **UI polish** — Skeleton loaders, toast notifications, form validation (Formz), staggered animations, cached avatars
- **Observability** — Talker logs for Dio, BLoC, and in-app debug console (long-press profile avatar)
- **Navigation** — GoRouter tab shell + deep links to trip detail/tracking

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
```

### 2. Maps (flutter_map)

Maps use **OpenStreetMap** tiles via `flutter_map` — no API key required for the demo.

Tile URL is configured in `lib/core/utils/map_config.dart`. Tiles are cached on disk via `flutter_map_cache` + `http_cache_file_store` (see `lib/core/utils/map_tile_cache.dart`).

**Routing** uses the free [OSRM demo server](https://router.project-osrm.org/) through `RouteService`. Routes are memory-cached and fall back to a straight line when offline. Attribution: © [OSRM contributors](https://project-osrm.org/).

For production, consider a tile provider with usage terms that fit your app (Mapbox, Stadia, self-hosted tiles, etc.) and a dedicated routing backend with rate limits.

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

## Offline & cache behavior

| Resource | Local store | Stale-while-revalidate | Offline writes |
|----------|-------------|------------------------|----------------|
| Trips | `trips_box` | Trip list BLoC | Pending sync queue (`createTrip`, `updateTripStatus`) |
| Orders | `orders_box` | Order tab BLoC | Read-only cache |
| Profile | `user_box` | Profile `FutureBuilder` + `cachedUser` | Local wallet only |
| Notifications | `notifications_box` | Seeded from `assets/mock/notifications.json` | FCM / simulate |
| Routes | `route_cache_box` | Memory → disk → OSRM → straight line | N/A |
| Map tiles | File cache (`map_tiles/`) | flutter_map_cache | N/A |

- **`NetworkStatus`** — shared link-type online check (Wi‑Fi without internet may still show online).
- **`SyncService.syncAll()`** — drains trip pending sync, refreshes orders and profile on reconnect or manual sync.
- **Cache TTL** — remote fetches skipped for 5 minutes when cache is non-empty (`cache_meta_box`), unless `forceRefresh: true`.

## Architecture

```
lib/
├── config/              # routes (GoRouter), theme tokens (AppColors, Light/DarkTheme), EnvConfig
├── core/                # ApiClient, failures, use cases, connectivity, cache (Hive sync), sync, map utils
├── shared/              # AppSpacing, AppButton, offline banner, toasts
├── features/
│   ├── settings/        # SettingsCubit (theme + locale)
│   ├── auth/            # shared/ + splash, onboarding, auth_select, login, register, forgot_password
│   ├── home/            # main_shell, map_view, ride_request
│   ├── trips/           # shared/ + trip_list, trip_detail, tracking
│   ├── notifications/   # shared/ + notification_list
│   └── profile/         # shared/ + profile_view, orders
├── app.dart             # MaterialApp.router + global BLoC providers
├── injection_container.dart
└── main.dart
```

See [AGENTS.md](AGENTS.md) for conventions. Extended docs: [tech_readme_files/INDEX.md](tech_readme_files/INDEX.md).

## Package highlights

| Area | Packages |
|------|----------|
| Maps | `flutter_map`, `flutter_map_animations`, `flutter_map_location_marker`, `flutter_map_cache`, `http_cache_file_store` |
| Routing | OSRM via `dio` (`RouteService`) |
| UI/UX | `skeletonizer`, `flutter_animate`, `toastification`, `formz`, `google_fonts`, `cached_network_image` |
| External nav | `url_launcher` — Open in Google/Apple Maps |

## Testing

```bash
flutter test
```

Includes `bloc_test` coverage for `TripListBloc` and `OrderBloc`, unit tests for `RouteService` (OSRM parsing, memory/disk cache, offline fallback), and pending sync queue dedupe.

## Freelance pitch

This template demonstrates production patterns clients expect from ride-hailing / delivery MVPs:

- Swap mock JSON API for real REST/GraphQL backend
- Extend Hive sync for conflict resolution
- Plug in Stripe/wallet payments
- Scale BLoCs per feature team

## License

MIT — use freely in portfolios and client demos.
