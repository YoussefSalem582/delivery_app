# Changelog

All notable changes to Nokta will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> Doc-map entry point: [`tech_readme_files/INDEX.md`](tech_readme_files/INDEX.md). Live status: [`tech_readme_files/CURRENT_STATUS.md`](tech_readme_files/CURRENT_STATUS.md).

## [Unreleased]

### Changed

- **Onboarding logo animation** — replaced broken Hero/PageView approach with a simple anchored slide animation (center circle → top bar).

- **README** — refreshed with current feature set (Nominatim, per-km fares, two-phase tracking, native branding); hero logo switched to `assets/logo.png` at 560px width.

### Added

- **Native branding assets** — `flutter_launcher_icons` + `flutter_native_splash` generate Android/iOS app icons from `assets/app_icon.png` and native splash screens from `assets/logo.png` (surface `#F7F9FC` background); fixed Android adaptive icon XML (`mipmap-anydpi-v26`).

- **Real location search (Nominatim)** — pickup and dropoff use OpenStreetMap geocoding with debounced autocomplete, reverse geocode for GPS pickup, offline guard, and OSM attribution. Removed demo place catalog and GPS-offset dropoff coordinates.

### Fixed

- **Tracking page dispose crash** — `TrackingPage` holds bloc reference directly instead of `context.read` in `dispose()`.
- **OSRM route timeouts** — deduplicate concurrent `getRoute` calls, cache straight-line fallbacks, use 5s OSRM timeout, and skip OSRM for 5 min after failure on the same route key.

### Changed

- **Randomized driver placement** — `DriverPlacement` seeds a driver start near pickup (≤8 min approach), away from dropoff, per trip id; `getTripRoutePlan()` retries closer if OSRM approach ETA exceeds 8 min. Catalog driver GPS is UI-only (name/rating/vehicle).
- **Per-km pricing** — Fares computed as base + (distance × rate/km) per ride tier via `EstimateFareUseCase`; `RideSelectionSheet` shows dynamic prices and fare breakdown from OSRM route distance.
- **Two-phase live tracking** — `TrackingBloc` simulates driver → pickup → dropoff with distance-based progress/ETA, phase labels, remaining km, and `getTripRoutePlan()` two-leg routing.
- **12-hour clock (AM/PM) app-wide** — Centralized `formatAppClockTime` / `formatTripDate` / `formatAppDateTime` in `date_time_format.dart`; chat bubbles, ride ETA labels, trip/notification timestamps, and order details use 12-hour format; `MaterialApp` forces `alwaysUse24HourFormat: false`.

### Removed

- **Demo place catalog** — `DemoPlace`, `DemoDestinations`, and GPS-offset dropoff coordinates replaced by Nominatim geocoding.

### Added (prior)

- **Destination autocomplete (demo)** — superseded by Nominatim real location search above.
- **Pricing domain** — `PricingConfig`, `TierPricing`, `FareEstimate`, `EstimateFareUseCase` (Economy/Premium/Delivery base + per-km rates with minimum fare).
- **Route geometry helpers** — `concatenateRoutes`, `totalRouteDistance`, `progressAtDistance`, `remainingDistanceMeters`, `projectPointOntoRoute` for accurate tracking simulation.
- **Driver placement** — `DriverPlacement.randomStartNearPickup()` for deterministic per-trip driver GPS near pickup, separated from dropoff, capped at ~8 min straight-line approach.
- **Tracking phase UI** — `tracking_phase_approach`, `tracking_phase_on_trip`, `tracking_remaining_km`, `fare_base_plus_distance` localization keys (EN + AR).

- **Trips list — current trip + history sections** — `TripListPage` splits active trips into a pinned `CurrentTripCard` (with Track CTA) and a `Trip History` list below; `partitionTrips` helper on `TripEntity`.
- **Connected trip data flow** — shell-scoped `TripListBloc` syncs from Hive after ride request, tracking completion, trip detail status changes, FCM notifications, and reconnect sync; tracking persists `inProgress`/`completed` to repository.
- **Unified trip quote data** — fare, distance, ETA, payment method, and ride tier flow from ride selection into `TripEntity` and display consistently on list, tracking, and detail screens; mock API assigns catalog drivers with full profile fields.
- **Tracking performance + sync** — cap densified route points to prevent map jank on long fallback routes; debounce trip-list cache sync; skip redundant list rebuilds when Hive snapshot unchanged; tracking uses same pickup→dropoff route/ETA as booking.
- **Driver profile screen** — `DriverProfilePage` at `/trips/:tripId/driver` merges trip + mock driver data; ratings & reviews section with star breakdown and review cards from mock API.
- Chat layer: `ChatMessageEntity`, `ChatLocalDataSource`, `ChatRepository`, `GetChatMessagesUseCase`, `SendChatMessageUseCase`, `DriverChatBloc`, `DriverCallBloc`.
- **Functional UI controls** — Shell tab AppBars use Nokta logo instead of stub hamburger menus; `ProfileAvatarButton` navigates to profile tab; wallet top-up, profile edit, order details, ride payment/promo pickers wired with demo actions.
- Shared widgets: `ShellAppBarLogo`, `ProfileAvatarButton`; `launchSms` in `phone_launcher.dart`; `AuthRepository.updateProfile`; Profile BLoC events `ProfileWalletTopUpRequested`, `ProfileUpdateRequested`.
- Localization keys for wallet top-up, driver messaging, payment/promo, profile edit, and order details (EN + AR).
- **AI agent documentation surface** — Canonical [`AGENTS.md`](AGENTS.md) plus tool shims ([`CLAUDE.md`](CLAUDE.md), [`CURSOR.md`](CURSOR.md), [`.codex/AGENTS.md`](.codex/AGENTS.md), [`.github/copilot-instructions.md`](.github/copilot-instructions.md)), [`.agents/skills/`](.agents/skills/) (3 project-tuned + 19 official Flutter/Dart skills), [`.cursor/rules/`](.cursor/rules/), [`.claude/commands/`](.claude/commands/), [`tech_readme_files/`](tech_readme_files/) doc map, and doc-hygiene scripts + CI ([`.github/workflows/docs.yml`](.github/workflows/docs.yml)).

## [1.0.0] - 2026-05-27

Pubspec: `1.0.0+1`. Initial Nokta ride-hailing / delivery MVP template.

### Added

- Clean Architecture + BLoC with sub-feature folders (`auth/`, `home/`, `trips/`, `notifications/`, `profile/`, `settings/`)
- Offline-first Hive cache, pending sync queue, reconnect sync via `SyncService`
- Live map tracking with `flutter_map`, OSRM routing, tile disk cache
- FCM push notifications with simulated fallback
- Bilingual EN/AR via `easy_localization`, dark/light themes
- GoRouter tab shell, auth flow, trip list/detail/tracking screens
- Talker observability (Dio, BLoC, in-app debug console)

## Version History

| Version | Date | Notes |
|---------|------|-------|
| 1.0.0 | 2026-05-27 | Initial MVP template |
