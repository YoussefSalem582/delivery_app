# Nokta — Agent Instructions

<!-- canonical-banner:start -->
> **Canonical source of truth for AI agents.**
> This file is the single authoritative guide for every agent (Cursor, Claude Code, Codex CLI, GitHub Copilot, Gemini, Aider, Windsurf, generic). The per-tool instruction files below are **thin shims** that pull in tool-specific runtime conventions and reference this document for everything else — do **not** duplicate content from this file into them.
>
> | Tool | Shim file | What lives only in the shim |
> |------|-----------|------------------------------|
> | All / generic | [.agents/AGENTS.md](.agents/AGENTS.md) | Skill folder location, `npx skills` workflow |
> | Claude Code | [CLAUDE.md](CLAUDE.md) | Tool-use rules, response style, slash-commands (`.claude/commands/`) |
> | OpenAI Codex CLI | [.codex/AGENTS.md](.codex/AGENTS.md) | Approval-mode mapping, `apply_patch` preference |
> | GitHub Copilot | [.github/copilot-instructions.md](.github/copilot-instructions.md) | Inline-completion + Copilot-Chat conventions |
> | Cursor | [CURSOR.md](CURSOR.md) + [.cursor/rules/](.cursor/rules/) `*.mdc` | Auto-attached rule scopes |
>
> **If you edit project conventions, edit this file.** Shims should never grow back into full mirrors.
<!-- canonical-banner:end -->

> **Scope**: Only modify files inside `delivery_app/` (this repo).

## Table of Contents

- [Project Overview](#project-overview)
- [Key Entry Points](#key-entry-points)
- [Feature Architecture](#feature-architecture)
- [Design Tokens — Never Hardcode](#design-tokens--never-hardcode)
- [State Management (BLoC)](#state-management-bloc)
- [Offline-First Architecture](#offline-first-architecture)
- [Geocoding & Location](#geocoding--location)
- [Maps & Tracking](#maps--tracking)
- [Pricing](#pricing)
- [Branding & Native Assets](#branding--native-assets)
- [Date & Time Formatting](#date--time-formatting)
- [API Integration](#api-integration)
- [DI Registration](#di-registration)
- [Localization](#localization)
- [Security](#security)
- [Shared Widgets](#shared-widgets)
- [Naming Conventions](#naming-conventions)
- [Mandatory Documentation (after every change)](#mandatory-documentation-after-every-change)
- [Approved Commands (no user prompt required)](#approved-commands-no-user-prompt-required)
- [Available Skills](#available-skills)

## Project Overview

Flutter ride-hailing / delivery MVP template (**Nokta**). Current version: **`1.0.0+1`**.

- **Architecture**: Clean Architecture + BLoC, sub-feature folders under `lib/features/<domain>/`
- **State**: `flutter_bloc` (BLoC for features, Cubit for settings/connectivity)
- **Routing**: GoRouter — use `RouteNames` in `lib/config/routes/route_names.dart`, never hardcode paths
- **DI**: GetIt in `lib/injection_container.dart`
- **Networking**: Dio via `ApiClient` + `MockApiInterceptor` for demo JSON
- **Storage**: Hive boxes for trips, orders, user, notifications, routes; `SharedPreferences` for settings and saved home/work places
- **Secrets**: `--dart-define` + `EnvConfig` — never hardcode API keys
- **Localization**: `easy_localization` + JSON in `assets/translations/` (EN + AR, RTL)
- **Geocoding**: OpenStreetMap Nominatim — debounced autocomplete, reverse geocode, offline guard (`home/shared/` geocoding layer)
- **Firebase**: Firebase Core + FCM (optional — app runs with simulated notifications)
- **Observability**: Talker (`talker_flutter`, `talker_dio_logger`, `talker_bloc_logger`)
- **Offline-First**: `ConnectivityCubit` + Hive cache + `SyncService` + pending sync queue
- **Maps**: `flutter_map` (OpenStreetMap tiles), OSRM routing via `RouteService`, tile disk cache
- **Pricing**: Per-km fares by tier (Economy / Premium / Delivery) via `EstimateFareUseCase` + OSRM route distance
- **Tracking**: Two-phase simulation (driver → pickup → dropoff), randomized driver placement near pickup (≤8 min approach)
- **Branding**: Native launcher icons + splash from `assets/app_icon.png` / `assets/logo.png`; in-app wordmark via `assets/logo.svg`
- **Platform**: Windows 11 development environment (PowerShell-first scripts)

## Key Entry Points

| File | Purpose |
|------|---------|
| `lib/main.dart` | Init: Firebase, Hive, DI, EasyLocalization |
| `lib/app.dart` | MaterialApp.router + global providers |
| `lib/injection_container.dart` | GetIt registrations |
| `lib/config/routes/app_router.dart` | GoRouter + auth redirects |
| `lib/config/routes/route_names.dart` | All route name constants |
| `lib/core/api/api_client.dart` | Dio wrapper + interceptors |
| `lib/core/network/route_service.dart` | OSRM routing, route cache, `getTripRoutePlan()` |
| `lib/core/utils/driver_placement.dart` | Deterministic random driver start near pickup |
| `lib/features/home/shared/` | Nominatim geocoding (repository, datasource, use cases) |
| `lib/features/home/ride_request/presentation/cubit/location_search_cubit.dart` | Debounced place search UI state |
| `lib/features/trips/shared/domain/usecases/estimate_fare_usecase.dart` | Per-km fare by ride tier |
| `lib/shared/utils/date_time_format.dart` | 12-hour clock formatters app-wide |
| `pubspec.yaml` | `flutter_launcher_icons` + `flutter_native_splash` config |

## Feature Architecture

Features live under `lib/features/<domain>/` with a **`shared/`** layer (data + domain) and **sub-features** (presentation only):

```
features/<domain>/
├── shared/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   └── domain/
│       ├── entities/
│       ├── repositories/
│       └── usecases/
└── <sub_feature>/          # e.g. trip_list, tracking, login
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

**Examples**: `auth/shared/` + `auth/login/`, `home/shared/` (geocoding) + `home/ride_request/`, `trips/shared/` + `trips/trip_list/`, `profile/shared/` + `profile/orders/`.

**Dependency rule**: Presentation → Domain ← Data. Domain has zero Flutter imports.

## Design Tokens — Never Hardcode

| Category | Use | Never |
|----------|-----|-------|
| Colors | `AppColors.primary`, `AppColors.error` | `Color(0xFF...)`, `Colors.blue` |
| Spacing | `AppSpacing.md`, `AppSpacing.lg` | raw `16.0` |
| Radius | `AppSpacing.radiusMd`, `AppSpacing.radiusLg` | raw `BorderRadius.circular(8)` |
| Routes | `RouteNames.home`, `RouteNames.tracking` | `'/home'` |
| Strings | `'key'.tr()` via easy_localization | raw user-facing strings |

## State Management (BLoC)

```dart
// Event (features/*/presentation/bloc/*_event.dart)
abstract class FeatureEvent extends Equatable { const FeatureEvent(); }

// State (features/*/presentation/bloc/*_state.dart)
abstract class FeatureState extends Equatable { const FeatureState(); }
class FeatureInitial extends FeatureState {}
class FeatureLoading extends FeatureState {}
class FeatureLoaded extends FeatureState {
  final DataType data;
  const FeatureLoaded({required this.data});
  @override List<Object?> get props => [data];
}
class FeatureError extends FeatureState {
  final String message;
  const FeatureError({required this.message});
  @override List<Object?> get props => [message];
}

// BLoC — inject use cases, use result.fold() for Either handling
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc({required this.useCase}) : super(FeatureInitial()) {
    on<LoadData>(_onLoad);
  }
}
```

- BLoCs call **use cases** returning `Either<Failure, T>` (dartz), not repositories directly
- `BlocBuilder` for UI rebuilds, `BlocListener` for side effects, `BlocConsumer` for both
- Talker logs BLoC transitions via `TalkerBlocObserver` (configured in `main.dart`)

## Offline-First Architecture

### Connectivity

- `ConnectivityCubit` is globally provided in `app.dart`
- Read status: `context.read<ConnectivityCubit>().state.isOnline`

### Cache (reads)

- Hive boxes: `trips_box`, `orders_box`, `user_box`, `notifications_box`, `route_cache_box`
- Cache metadata TTL: 5 minutes (`cache_meta_box`) — skip remote fetch when fresh unless `forceRefresh: true`
- Stale-while-revalidate in trip/order list BLoCs

### Pending sync (writes)

- `PendingSyncLocalDataSource` queues trip mutations when offline
- `SyncService.syncAll()` drains queue on reconnect or manual sync from profile

## Geocoding & Location

- **Layer**: `lib/features/home/shared/` — `NominatimRemoteDataSource`, `GeocodingRepositoryImpl`, `SearchPlaces`, `ReverseGeocode`
- **UI**: `LocationSearchCubit` — debounced autocomplete, cancel in-flight requests, offline guard
- **Saved places**: home/work quick chips via `SavedPlacesLocalDataSource` (SharedPreferences)
- **Attribution**: Show OSM attribution where required; respect Nominatim usage policy in production (use own instance or commercial geocoder)
- **Removed**: demo place catalog (`DemoPlace`, `DemoDestinations`) — do not reintroduce GPS-offset fake coordinates

## Maps & Tracking

- Map widget: `lib/core/widgets/delivery_map.dart`
- Tile config: `lib/core/utils/map_config.dart`; disk cache: `map_tile_cache.dart`
- Routing: `RouteService` → OSRM demo server; deduplicated concurrent requests, 5s timeout, failure backoff, straight-line fallback offline
- Two-leg routes: `getTripRoutePlan()` — driver → pickup → dropoff via `DriverPlacement.randomStartNearPickup()` (seeded by trip id, ≤8 min approach, retries closer if OSRM ETA too high)
- Tracking: `TrackingBloc` — two-phase simulation with distance-based progress/ETA, phase labels, remaining km; animated driver marker on `TrackingPage`
- Route geometry helpers: `concatenateRoutes`, `totalRouteDistance`, `progressAtDistance`, `remainingDistanceMeters`, `projectPointOntoRoute`

## Pricing

- Domain: `PricingConfig`, `TierPricing`, `FareEstimate` in `features/trips/shared/domain/`
- Use case: `EstimateFareUseCase` — base fare + (distance × rate/km) per tier with minimum fare
- UI: `RideSelectionSheet` shows dynamic prices and fare breakdown from OSRM route distance
- Quote data flows into `TripEntity` and displays consistently on list, tracking, and detail screens

## Branding & Native Assets

| Asset | Use |
|-------|-----|
| `assets/logo.svg` | In-app wordmark — `AppBrandIcon`, `AppAssets.logo` |
| `assets/logo.png` | Horizontal wordmark — native splash screen |
| `assets/app_icon.png` | Square icon — Android adaptive + iOS launcher |

Regenerate native assets after changing logos (full app restart required to see splash):

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Config lives in `pubspec.yaml` (`flutter_launcher_icons`, `flutter_native_splash`). Splash background: `#F7F9FC` (`AppColors.surface`).

## Date & Time Formatting

- Centralized in `lib/shared/utils/date_time_format.dart`
- Use `formatAppClockTime`, `formatTripDate`, `formatAppDateTime` — 12-hour AM/PM app-wide
- `MaterialApp` forces `alwaysUse24HourFormat: false`

## API Integration

1. Add path constant if needed (or use mock interceptor paths)
2. Add method to remote data source using `ApiClient`
3. Create/update model with `fromJson`/`toJson`
4. Add method to domain repository contract returning `Either<Failure, T>`
5. Implement in repository with exception → failure mapping
6. Create use case extending `UseCase<ReturnType, Params>`
7. Wire into BLoC; register in `injection_container.dart`

Demo mode: `MockApiInterceptor` serves JSON from `assets/mock/`.

External APIs (not mocked): Nominatim geocoding and OSRM routing use real HTTP via Dio — guard offline in UI, respect rate limits in production.

## DI Registration

```dart
sl.registerLazySingleton(() => FeatureRemoteDataSource(apiClient: sl()));
sl.registerLazySingleton<FeatureRepository>(() => FeatureRepositoryImpl(dataSource: sl()));
sl.registerLazySingleton(() => GetFeatureUseCase(repository: sl()));
sl.registerFactory(() => FeatureBloc(useCase: sl()));  // Factory — new instance per screen
```

## Localization

- All user-facing strings: `'some_key'.tr()` or `context.tr('some_key')`
- Add keys to **both** `assets/translations/en.json` and `assets/translations/ar.json`
- Never use raw strings in UI widgets
- App display name is **Nokta** (`AppConstants.appName` / `app_name` key)

## Security

- Never hardcode API URLs, tokens, or keys in Dart source
- Secrets via `--dart-define` + `EnvConfig` when adding real API keys
- Demo auth uses `SharedPreferences` / Hive — use `FlutterSecureStorage` when wiring production auth

## Shared Widgets

Check `lib/shared/widgets/` and `lib/core/widgets/` before building new UI:

**Inputs**: `AppTextField`
**Buttons**: `AppButton`, `NoktaPrimaryButton`
**Branding**: `AppBrandIcon` (`assets/logo.svg`), `AppAssets`
**Navigation**: bottom nav in `main_shell`
**Maps**: `DeliveryMap`
**Feedback**: Talker console (long-press profile avatar), toastification

## Naming Conventions

| Item | Convention |
|------|-----------|
| Files | `snake_case.dart` |
| Classes | `PascalCase` |
| Variables/functions | `camelCase` |
| Private members | `_prefixed` |

## Mandatory Documentation (after every change)

1. `CHANGELOG.md` — add entry under the current version (Keep a Changelog format)
2. `tech_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md` — dated entry at top
3. `tech_readme_files/CURRENT_STATUS.md` — update feature status and metrics

## Approved Commands (no user prompt required)

| Category | Command |
|----------|---------|
| Dart/Flutter | `flutter pub get`, `flutter analyze`, `flutter test`, `dart format <path>`, `dart run build_runner build` |
| Branding codegen | `dart run flutter_launcher_icons`, `dart run flutter_native_splash:create` |
| Doc tooling | `.\scripts\sync_ai_ignores.ps1`, `.\scripts\sync_ai_ignores.ps1 -Check`, `.\scripts\check_docs_freshness.ps1`, `.\scripts\check_skills_drift.ps1` |
| Skills sync | `npx skills update`, `npx skills check` |
| Lint | `npx markdownlint-cli2 "**/*.md"` |

## Available Skills

All skill prompts live in `.agents/skills/` — auto-discovered by Cursor, Claude Code, Codex, Copilot, and other agents.

### Project-tuned skills

| Skill | When to use |
|-------|------------|
| `add-feature` | Scaffold a Clean Architecture feature (shared/ + sub-feature), DI, routing, translations |
| `add-api` | Wire a backend endpoint end-to-end through `ApiClient` and offline queue |
| `add-language` | Add or update localization strings in `en.json` + `ar.json` |

### Official Flutter skills (`flutter/skills`)

Prefer project-tuned skills for overlapping workflows.

| Skill | When to use |
|-------|------------|
| `flutter-add-widget-test` | Widget tests with `WidgetTester` |
| `flutter-add-integration-test` | Integration tests |
| `flutter-fix-layout-issues` | RenderFlex overflow, constraint issues |
| `flutter-build-responsive-layout` | Phone/tablet layouts |
| `flutter-setup-declarative-routing` | **Skip** — go_router already configured |
| `flutter-setup-localization` | **Skip** — use `add-language` instead |
| `flutter-use-http-package` | **Skip** — we use Dio |

### Official Dart skills (`dart-lang/skills`)

| Skill | When to use |
|-------|------------|
| `dart-add-unit-test` | Unit tests with `package:test` |
| `dart-fix-runtime-errors` | Stack trace → fix → verify |
| `dart-run-static-analysis` | `dart analyze` + `dart fix` |
| `dart-generate-test-mocks` | **Skip** — we use `mocktail` |

Update official skills: `npx skills update`
