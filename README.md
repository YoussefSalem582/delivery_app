<p align="center">
  <img src="assets/logo.png" alt="Nokta logo" width="560" />
</p>

<h1 align="center">Nokta</h1>

<p align="center"><strong>Flutter Ride-Hailing / Delivery MVP</strong></p>

<p align="center">
  <strong>Version:</strong> <code>1.0.0+1</code> · Scalable Uber-like template with real geocoding, live tracking, and offline-first cache
</p>

<p align="center">
  Clean Architecture + BLoC · Hive offline cache · Nominatim search · OSRM routing · per-km fares · EN/AR · dark/light themes
</p>

<p align="center">
  <a href="tech_readme_files/CURRENT_STATUS.md">Live status</a> ·
  <a href="CHANGELOG.md">Changelog</a> ·
  <a href="AGENTS.md">Agent conventions</a> ·
  <a href="tech_readme_files/INDEX.md">Full docs</a>
</p>

---

## Overview

**Nokta** is a production-pattern Flutter template for ride-hailing and delivery apps. It ships six feature domains (auth, home, trips, notifications, profile, settings), a mock JSON API you can swap for a real backend, and polished UX patterns clients expect from an MVP — without locking you into a specific map or payment provider.

| Area | What you get |
|------|----------------|
| **Architecture** | Clean Architecture per domain: `shared/` (data + domain) + presentation sub-features |
| **State** | `flutter_bloc` — BLoCs for features, Cubits for settings/connectivity |
| **Routing** | GoRouter with `RouteNames`, auth redirects, tab shell |
| **Offline** | Hive cache, 5-min TTL, stale-while-revalidate, pending sync queue |
| **Maps** | `flutter_map` + OpenStreetMap tiles, OSRM routes, disk tile cache |
| **Location** | Nominatim geocoding — debounced autocomplete, reverse geocode, saved home/work |
| **Tracking** | Two-phase driver simulation (pickup → dropoff), per-km ETA, phase labels |
| **Pricing** | Dynamic fares: base + distance × tier rate from OSRM route length |
| **i18n** | English + Arabic (RTL) via `easy_localization` |
| **Branding** | Native launcher icons + splash from `assets/logo.png` / `assets/app_icon.png` |
| **Observability** | Talker — Dio, BLoC, and in-app debug console |

## Features

### Core platform

- **Clean Architecture** — per-feature `shared/` (data + domain) + sub-features (`auth/login/`, `trips/tracking/`, etc.)
- **Use cases** — BLoCs call use cases returning `Either<Failure, T>` (dartz)
- **DI** — GetIt in `injection_container.dart`
- **Networking** — Dio + `MockApiInterceptor` for demo JSON under `assets/mock/`
- **Secrets** — `--dart-define` + `EnvConfig` (no hardcoded API keys)

### Offline-first

- **Hive boxes** — trips, orders, user, notifications, route cache, cache metadata
- **Stale-while-revalidate** — trip/order list BLoCs show cache immediately, refresh in background
- **Pending sync queue** — trip create/status mutations queued offline, drained on reconnect
- **Dual sync** — `ConnectivityCubit` reconnect sync + `workmanager` background stub
- **Route cache** — memory → disk (50-entry LRU) → OSRM → straight-line fallback

### Maps, location & tracking

- **Real location search** — OpenStreetMap Nominatim for pickup and dropoff with debounced autocomplete, reverse geocode for GPS pickup, offline guard, OSM attribution
- **Saved places** — home/work quick chips via SharedPreferences
- **OSRM routing** — road-following polylines via free demo server; deduplicated requests, 5s timeout, failure backoff
- **Live tracking** — two-phase simulation (driver → pickup → dropoff), randomized driver placement near pickup (≤8 min approach), distance-based progress/ETA, remaining km labels
- **Per-km pricing** — Economy / Premium / Delivery tiers via `EstimateFareUseCase`; fare breakdown in ride selection sheet
- **Map UX** — animated camera, live location marker, tile disk cache, external open in Google/Apple Maps

### Auth & onboarding

- Splash with auth check, onboarding flow, login/register/forgot-password (demo credentials)
- Native splash screen shows centered `assets/logo.png` on `#F7F9FC` background (Android 12+ supported)

### UI & UX

- Dark/light themes, Inter + Cairo typography (locale-aware)
- Skeleton loaders, toast notifications, Formz validation, staggered animations
- 12-hour clock (AM/PM) app-wide
- Trips list: pinned **Current Trip** card + **Trip History** section
- Driver profile, in-trip chat + call on tracking/detail screens

### Notifications & profile

- Firebase Cloud Messaging + simulated fallback when Firebase is not configured
- Profile: wallet top-up (Hive-local demo), edit name, orders tab with order details

## Screens

| Screen | Description |
|--------|-------------|
| Splash | Brand logo, auth check, fade-in animation |
| Onboarding | First-run intro flow |
| Login / Register | Demo auth (any credentials) |
| Home | Live map, destination search (Nominatim), ride request sheet, payment/promo pickers |
| Trips | Current trip card + history list, pull-to-refresh, offline badge |
| Trip Detail | Status timeline, driver info, chat/call, track CTA |
| Tracking | Real-time map, two-phase polyline, ETA card, phase labels |
| Notifications | In-app alerts from FCM / simulated events |
| Profile | Wallet, orders, theme/locale, manual sync, Talker console (long-press avatar) |

## Prerequisites

- Flutter 3.16+ (SDK `^3.12.0`)
- Android Studio / Xcode for device builds
- Internet for map tiles (OpenStreetMap) and Nominatim/OSRM (demo servers)
- Firebase project (optional — app runs with simulated notifications)

## Setup

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run

```bash
flutter run
```

Do a **full restart** (not hot reload) after changing native splash or launcher icons.

### 3. Maps & routing

Maps use **OpenStreetMap** tiles via `flutter_map` — no API key required for the demo.

| Config | File |
|--------|------|
| Tile URL | `lib/core/utils/map_config.dart` |
| Tile disk cache | `lib/core/utils/map_tile_cache.dart` |
| OSRM routing | `lib/core/services/route_service.dart` |

Routing uses the free [OSRM demo server](https://router.project-osrm.org/). Routes are cached and fall back to a straight line when offline. Attribution: © [OSRM contributors](https://project-osrm.org/).

Geocoding uses the [Nominatim](https://nominatim.org/) API (OpenStreetMap). Respect usage policy in production — use your own instance or a commercial geocoder.

For production, consider a tile provider with terms that fit your app (Mapbox, Stadia, self-hosted tiles) and dedicated routing/geocoding backends with rate limits.

### 4. Firebase (optional)

1. Create a Firebase project and add Android + iOS apps.
2. Download `google-services.json` → `android/app/`
3. Download `GoogleService-Info.plist` → `ios/Runner/`
4. Run `flutterfire configure` or add the Firebase Gradle plugin manually.

Without Firebase, the app still runs — trip notifications are simulated via `FcmService.simulateTripNotification`.

### 5. Regenerate app icon & native splash

Icons and splash are generated from assets via `flutter_launcher_icons` and `flutter_native_splash` (configured in `pubspec.yaml`):

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

| Asset | Purpose |
|-------|---------|
| `assets/app_icon.png` | Square launcher icon (Android adaptive + iOS) |
| `assets/logo.png` | Horizontal wordmark for native splash screen |
| `assets/logo.svg` | In-app branding (`AppBrandIcon`, splash page) |

## Demo flow

1. **Login** — use any email/password (e.g. `demo@delivery.app` / `password`)
2. **Home** — search pickup/dropoff with Nominatim autocomplete, or use home/work chips
3. **Ride request** — pick tier (Economy/Premium/Delivery), see dynamic fare from route distance
4. **Tracking** — watch two-phase driver animation (approach pickup → trip to dropoff)
5. **Trips** — see current trip pinned above history; pull to refresh
6. **Offline** — enable airplane mode, request a ride (queued locally), disable airplane mode, tap sync on profile — Talker logs sync
7. **Notifications** — request ride or simulate driver arrived on trip detail
8. **Profile** — toggle dark mode, switch to Arabic (RTL), long-press avatar for Talker console
9. **Complete trip** — from trip detail, tap Complete Trip

## Offline & cache behavior

| Resource | Local store | Stale-while-revalidate | Offline writes |
|----------|-------------|------------------------|----------------|
| Trips | `trips_box` | Trip list BLoC | Pending sync queue (`createTrip`, `updateTripStatus`) |
| Orders | `orders_box` | Order tab BLoC | Read-only cache |
| Profile | `user_box` | Profile cache-first load | Local wallet only |
| Notifications | `notifications_box` | Seeded from mock JSON | FCM / simulate |
| Routes | `route_cache_box` | Memory → disk → OSRM → straight line | N/A |
| Map tiles | File cache (`map_tiles/`) | `flutter_map_cache` | N/A |
| Saved places | SharedPreferences | Home/work chips | Local only |

- **`ConnectivityCubit`** — global online/offline state
- **`SyncService.syncAll()`** — drains trip pending sync, refreshes orders and profile on reconnect or manual sync
- **Cache TTL** — remote fetches skipped for 5 minutes when cache is non-empty (`cache_meta_box`), unless `forceRefresh: true`

## Architecture

```
lib/
├── config/              # routes (GoRouter), theme tokens (AppColors), EnvConfig
├── core/                # ApiClient, failures, use cases, connectivity, cache, sync, map utils
├── shared/              # AppSpacing, AppButton, branding, toasts, date/time formatters
├── features/
│   ├── settings/        # SettingsCubit (theme + locale)
│   ├── auth/            # shared/ + splash, onboarding, login, register, forgot_password
│   ├── home/            # shared/ (geocoding) + main_shell, map_view, ride_request
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
| Maps | `flutter_map`, `flutter_map_animations`, `flutter_map_cache`, `http_cache_file_store` |
| Location | `geolocator`, Nominatim via `dio` |
| Routing | OSRM via `dio` (`RouteService`) |
| State | `flutter_bloc`, `get_it`, `dartz`, `equatable` |
| UI/UX | `skeletonizer`, `flutter_animate`, `toastification`, `formz`, `google_fonts`, `cached_network_image`, `flutter_svg` |
| i18n | `easy_localization` |
| Observability | `talker_flutter`, `talker_dio_logger`, `talker_bloc_logger` |
| Branding | `flutter_launcher_icons`, `flutter_native_splash` |
| External nav | `url_launcher` — Open in Google/Apple Maps |

## Testing

```bash
flutter test
```

Coverage includes bloc tests (TripList, Order, Tracking, LocationSearch), RouteService unit tests (OSRM parsing, cache, offline fallback), fare estimate tests, route geometry tests, driver placement tests, Nominatim model tests, sync dedupe tests, and trip partition tests.

## Production roadmap

| Item | Status |
|------|--------|
| Mock JSON API | ✅ Demo |
| Real REST/GraphQL backend | 🚧 Swap `MockApiInterceptor` |
| Secure auth storage | 🚧 Planned (`FlutterSecureStorage`) |
| Real payments / wallet | 🚧 Demo top-up only (Hive-local) |
| Dedicated Nominatim / OSRM | 🚧 Use own instances in production |

## Freelance pitch

This template demonstrates production patterns clients expect from ride-hailing / delivery MVPs:

- Swap mock JSON API for real REST/GraphQL backend
- Extend Hive sync for conflict resolution
- Plug in Stripe/wallet payments
- Scale BLoCs per feature team
- Ship with native branding and bilingual RTL out of the box

## License

MIT — use freely in portfolios and client demos.
