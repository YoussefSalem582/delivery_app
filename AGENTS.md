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
- [Maps & Tracking](#maps--tracking)
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
- **Storage**: Hive boxes for trips, orders, user, notifications, routes; `SharedPreferences` for settings
- **Secrets**: `--dart-define` + `EnvConfig` — never hardcode API keys
- **Localization**: `easy_localization` + JSON in `assets/translations/` (EN + AR, RTL)
- **Firebase**: Firebase Core + FCM (optional — app runs with simulated notifications)
- **Observability**: Talker (`talker_flutter`, `talker_dio_logger`, `talker_bloc_logger`)
- **Offline-First**: `ConnectivityCubit` + Hive cache + `SyncService` + pending sync queue
- **Maps**: `flutter_map` (OpenStreetMap tiles), OSRM routing via `RouteService`, tile disk cache
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

**Examples**: `auth/shared/` + `auth/login/`, `trips/shared/` + `trips/trip_list/`, `profile/shared/` + `profile/orders/`.

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

## Maps & Tracking

- Map widget: `lib/core/widgets/delivery_map.dart`
- Tile config: `lib/core/utils/map_config.dart`; disk cache: `map_tile_cache.dart`
- Routing: `RouteService` → OSRM demo server; falls back to straight line offline
- Tracking: `TrackingBloc` + animated driver marker on `TrackingPage`

## API Integration

1. Add path constant if needed (or use mock interceptor paths)
2. Add method to remote data source using `ApiClient`
3. Create/update model with `fromJson`/`toJson`
4. Add method to domain repository contract returning `Either<Failure, T>`
5. Implement in repository with exception → failure mapping
6. Create use case extending `UseCase<ReturnType, Params>`
7. Wire into BLoC; register in `injection_container.dart`

Demo mode: `MockApiInterceptor` serves JSON from `assets/mock/`.

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
**Branding**: `AppBrandIcon`
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
