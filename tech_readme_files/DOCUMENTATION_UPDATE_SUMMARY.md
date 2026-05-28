# Documentation Update Summary

> Rolling log of documentation changes. Newest entries first.

---

## 2026-05-28 — Skills lock resync (CI)

**What changed:** Ran `npx skills update` to refresh `dart-migrate-to-checks-package` from upstream and updated `skills-lock.json` `computedHash` so `scripts/docs/check_skills_drift.sh` passes in docs workflow.

**Files touched:** `.agents/skills/dart-migrate-to-checks-package/SKILL.md`, `skills-lock.json`

---

## 2026-05-28 — Web PWA icons aligned with mobile

**What changed:** `flutter_launcher_icons` `web:` config generates favicon + 192/512/maskable icons from `assets/app_icon.png`; `web/manifest.json` branded as Nokta with primary theme color.

**Files touched:** `pubspec.yaml`, `web/icons/**`, `web/favicon.png`, `web/manifest.json`

---

## 2026-05-28 — Web client demo (Device Preview + GitHub Pages)

**What changed:** Flutter Web platform; `device_preview` shell on `kIsWeb`; Photon geocoding for browser CORS; web guards for Workmanager and map tile disk cache; `map_launcher` without `dart:io`; GitHub Actions deploy to Pages on `feature/web-client-demo` push.

**Demo URL (after merge + Pages setup):** https://youssefsalem582.github.io/delivery_app/

**One-time setup:** Repo Settings → Pages → Source: **GitHub Actions**

**Files touched:** `web/**`, `pubspec.yaml`, `lib/main.dart`, `lib/app.dart`, `lib/core/utils/map_launcher.dart`, `lib/core/sync/sync_service.dart`, `lib/core/utils/map_tile_cache.dart`, `lib/features/home/shared/data/datasources/photon_remote_datasource.dart`, `lib/features/home/shared/data/repositories/geocoding_repository_impl.dart`, `lib/injection_container.dart`, `.github/workflows/deploy-web-demo.yml`, `README.md`

---

## 2026-05-28 — Driver offer preview + passenger sheet

**What changed:** Offer cards open `DriverOfferPreviewPage` (OSRM route map, passenger info, accept/decline); `TrackingRiderRow` on driver active-trip sheet; `RiderEntity` + `GetRiderForTripUseCase` + `assets/mock/riders.json`.

**Files touched:** `lib/features/driver/offers/**`, `lib/features/trips/shared/**`, `lib/features/trips/tracking/**`, `lib/features/driver/home/**`, `assets/mock/riders.json`, `assets/translations/*`, tests

---

## 2026-05-28 — Driver active trip unified with live tracking

**What changed:** Driver active trip uses shared `LiveTrackingPage` + `TrackingBloc` driver mode (OSRM route, animated marker, bottom sheet ETA/phase, driver status buttons, location publish); `DriverActiveTripPage` is a thin wrapper; `DriverActiveTripBloc` removed from DI.

**Files touched:** `lib/features/trips/tracking/**`, `lib/features/driver/active_trip/presentation/pages/driver_active_trip_page.dart`, `lib/features/driver/home/presentation/pages/driver_home_page.dart`, `lib/injection_container.dart`, `test/tracking_bloc_test.dart`

---

## 2026-05-28 — Driver home on-trip state fix

**What changed:** Driver home no longer shows "Go online" while `onTrip`; stale on-trip lock clears when jobs have no active assignment; completing a trip returns driver to online.

**Files touched:** `driver_home_page.dart`, `driver_availability_cubit.dart`

---

## 2026-05-28 — Driver/passenger widget deduplication (phase 2)

**What changed:** `ProfileUserCard` hero variant; passenger wallet on `StatSummaryCard`; `performAppLogout`, `AppModeSwitchTile`, `NotificationShellScaffold`, `MapTripScaffold`; profile/orders/trip-history empty states on `EmptyStateView`; notifications on `ShellTabScaffold` (66 tests passing).

**Files touched:** `lib/shared/widgets/profile/**`, `lib/shared/widgets/navigation/notification_shell_scaffold.dart`, `lib/core/widgets/map_trip_scaffold.dart`, `lib/features/auth/shared/presentation/utils/app_logout.dart`, `lib/features/profile/**`, `lib/features/driver/**`, `lib/features/home/main_shell/**`, `lib/features/notifications/**`, `lib/features/trips/tracking/**`

---

## 2026-05-28 — Shared driver/passenger widgets

**What changed:** Consolidated duplicated UI into shared widgets (`ShellTabAppBar`, `ShellTabScaffold`, `EmptyStateView`, `SectionHeader`, `TripAccentCard`, `ActiveTripSection`, `ProfileUserCard`, `StatSummaryCard`, `LogoutButton`); refactored driver home/jobs/profile and passenger trips/notifications/profile to use them.

**Files touched:** `lib/shared/widgets/**`, `lib/features/trips/shared/presentation/widgets/**`, `lib/features/driver/**`, `lib/features/trips/trip_list/**`, `lib/features/profile/**`, `lib/features/notifications/**`

---

## 2026-05-28 — Driver demo offer seed

**What changed:** Added `trip-demo-offer` to mock trips (requested, rider `user-rider-demo`) so single-account driver mode shows an offer; driver empty-state hint; removed redundant auth refresh after onboarding.

**Files touched:** `assets/mock/trips.json`, `assets/translations/*`, `driver_home_page.dart`, `driver_onboarding_page.dart`

---

## 2026-05-28 — Plan exit-criteria polish (round 2)

**What changed:** Added `SwitchAppModeUseCase`; vehicle-type dropdown (Economy/Premium/Delivery); registered-driver read-only onboarding summary; notification badge on driver shell home tab; full driver onboarding EN/AR strings; `SwitchAppModeUseCase` test (66 tests passing).

**Files touched:** `lib/features/driver/onboarding/**`, `lib/features/driver/main_shell/**`, `lib/features/driver/shared/domain/usecases/switch_app_mode_usecase.dart`, `assets/translations/*`, `test/switch_app_mode_usecase_test.dart`

---

## 2026-05-28 — Plan exit-criteria gaps

**What changed:** Wired `EnvConfig.useMockDriverApi` to `ApiEndpoints` (`/v1/driver/*` when false); mock interceptor normalizes v1 paths; driver availability offline queue; go-online connectivity guard; trip detail waiting-for-driver banner; `AppModeCubit` unit test (65 tests passing).

**Files touched:** `lib/core/network/api_endpoints.dart`, `mock_api_interceptor.dart`, `driver_availability_cubit.dart`, `driver_home_page.dart`, `trip_detail_page.dart`, `assets/translations/*`, `test/app_mode_cubit_test.dart`

---

## 2026-05-28 — Driver active trip mock location publish

**What changed:** `DriverActiveTripPage` publishes mock GPS every 5s via `updateDriverLocation` so rider `TrackingBloc` poll reads `driverLat`/`driverLng` from the shared trip record.

**Files touched:** `lib/features/driver/active_trip/presentation/pages/driver_active_trip_page.dart`

---

## 2026-05-28 — Dual-mode driver flow polish + sync

**What changed:** Completed remaining plan gaps: `DriverPendingSyncHandler` drains offline driver actions; rider `CurrentTripCard` waiting state; request-ride notification copy; FCM for driver offers/accept/complete; mock rider wallet debit on driver complete; entity Hive + onboarding cubit tests (63 tests passing).

**Files touched:** `lib/core/sync/driver_pending_sync_handler.dart`, `lib/features/driver/**`, `lib/features/trips/trip_list/**`, `lib/features/home/map_view/**`, `lib/core/network/mock_api_interceptor.dart`, `test/entity_hive_test.dart`, `test/driver_onboarding_cubit_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`

---

## 2026-05-28 — Dual-mode driver flow

**What changed:** Implemented full dual-mode driver flow on branch `feature/dual-mode-driver-flow`: extended `UserEntity`/`TripEntity`, `AppModeCubit`, driver onboarding, driver shell, mock dispatch, `AppDataCoordinator`, rider trip filters, subscriber tracking, EN/AR strings, ADR + API docs.

**Files touched:** `lib/features/driver/**`, `lib/core/sync/app_data_coordinator.dart`, `lib/core/network/mock_api_store.dart`, `lib/config/routes/app_router.dart`, `lib/features/profile/**`, `lib/features/trips/**`, `assets/translations/*`, `assets/mock/trips.json`, `test/trip_query_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`, `09_api_endpoints.md`, `decisions/001-dual-mode-driver-flow.md`

---

## 2026-05-27 — Notifications real trip data + category filters

**What changed:** Replaced All/Unread-only filters with All/Trip/Messages/Calls chips plus Unread toggle; `NotificationBloc` joins trips for live status chips and routes; added `message`/`call` notification types; aligned mock seed; chat/call flows emit notifications via `FcmService`.

**Files touched:** `lib/features/notifications/**`, `lib/features/trips/driver_chat/**`, `lib/features/trips/driver_call/**`, `lib/core/utils/ui_helpers.dart`, `lib/injection_container.dart`, `assets/mock/notifications.json`, `assets/translations/en.json`, `assets/translations/ar.json`, `CHANGELOG.md`, `CURRENT_STATUS.md`

---

## 2026-05-27 — Notifications dark mode contrast fix

**What changed:** Fixed near-invisible notification titles in dark mode by assigning `titleSmall`/`titleMedium` colors in `AppTextStyles` and explicit `NotificationTheme` text colors (`onSurface` titles, brighter section headers, app bar title/action). Prior dark polish (card elevation, accents) retained.

**Files touched:** `lib/config/theme/app_text_styles.dart`, `lib/features/notifications/notification_list/presentation/utils/notification_theme.dart`, `notification_tile.dart`, `notifications_page.dart`, `notification_empty_state.dart`, `CHANGELOG.md`

---

## 2026-05-27 — Notifications dark mode polish

**What changed:** Added `NotificationTheme` helper and applied theme-aware colors across inbox widgets — unread cards use higher elevation in dark, `inversePrimary` accent bar/dot/borders, subtle card shadow, filter bar border/segment styling, empty-state icon tint, and mark-all-read button color.

**Files touched:** `lib/features/notifications/notification_list/presentation/utils/notification_theme.dart`, `notification_tile.dart`, `notification_type_icon.dart`, `notification_filter_bar.dart`, `notification_empty_state.dart`, `notification_list_body.dart`, `notifications_page.dart`, `CHANGELOG.md`

---

## 2026-05-27 — Notifications list layout fix

**What changed:** Fixed `BoxConstraints forces an infinite height` on notifications tab by wrapping the tile `Row` in `IntrinsicHeight`.

**Files touched:** `lib/features/notifications/notification_list/presentation/widgets/notification_tile.dart`, `CHANGELOG.md`

---

## 2026-05-27 — Notifications inbox UX refactor

**What changed:** Refactored notifications tab into decomposed widgets with `NotificationType`, grouped list (Today/Yesterday/Earlier), All/Unread `SegmentedButton`, swipe-to-delete with undo snackbar, mark-all-read AppBar action, pull-to-refresh, `ErrorView` retry, and bottom-nav unread `Badge`.

**Files touched:** `lib/features/notifications/**`, `lib/shared/widgets/navigation/app_bottom_nav_bar.dart`, `lib/features/home/main_shell/presentation/pages/main_shell_page.dart`, `lib/core/network/fcm_service.dart`, `lib/core/cache/entities/hive_adapters.dart`, `assets/mock/notifications.json`, `assets/translations/en.json`, `assets/translations/ar.json`, `CHANGELOG.md`, `CURRENT_STATUS.md`

---

## 2026-05-27 — Onboarding top bar polish

**What changed:** Replaced "Nokta" text with theme-aware `AppBrandIcon` wordmark; redesigned skip control as a bordered pill button with forward arrow and improved tap target.

**Files touched:** `lib/features/auth/onboarding/presentation/widgets/onboarding_top_bar.dart`, `CHANGELOG.md`, `DOCUMENTATION_UPDATE_SUMMARY.md`

---

## 2026-05-27 — Splash screen refactor (2s minimum)

**What changed:** Refactored in-app splash into `SplashBackground`, `SplashContent`, and `SplashConfig`. Added gradient/dot background, staggered entrance animations, bottom progress bar, and a guaranteed 2-second minimum before auth-based navigation.

**Files touched:** `lib/features/auth/splash/presentation/**`, `CHANGELOG.md`, `CURRENT_STATUS.md`, `DOCUMENTATION_UPDATE_SUMMARY.md`

---

## 2026-05-27 — Theme-aware wordmark (PNG light/dark)

**What changed:** Replaced in-app SVG wordmark with theme-aware PNG assets — `assets/logo.png` in light mode, `assets/logo_light.png` in dark mode. Updated `AppBrandIcon`, `AppAssets`, logo precache, `pubspec.yaml` assets, and `flutter_native_splash` dark-mode config. Removed unused `flutter_svg` dependency.

**Files touched:** `lib/shared/widgets/branding/app_brand_icon.dart`, `lib/shared/assets/app_assets.dart`, `lib/core/utils/app_logo_cache.dart`, `pubspec.yaml`, native splash `res/` assets, `CHANGELOG.md`, `CURRENT_STATUS.md`, `AGENTS.md`

---

## 2026-05-27 — AI agent docs sync

**What changed:** Updated canonical `AGENTS.md` and all agent shims/rules (Cursor, Claude, Codex, Copilot, `.agents/rules/`) with latest features: Nominatim geocoding, per-km pricing, two-phase tracking, native branding assets, new key entry points. Updated `ONBOARDING.md` and `COMMON_PITFALLS.md` agent references.

**Files touched:** `AGENTS.md`, `CURSOR.md`, `CLAUDE.md`, `.agents/AGENTS.md`, `.codex/AGENTS.md`, `.github/copilot-instructions.md`, `.agents/rules/*`, `.cursor/rules/*`, `ONBOARDING.md`, `COMMON_PITFALLS.md`

---

## 2026-05-27 — README refresh

**What changed:** Updated root `README.md` with latest features (Nominatim geocoding, per-km pricing, two-phase tracking, native branding, production roadmap). Hero image now uses `assets/logo.png` at 560px width.

**Files touched:** `README.md`

---

## 2026-05-27 — App icon + native splash from Nokta logo

**What changed:** Wired `flutter_launcher_icons` and `flutter_native_splash` in `pubspec.yaml`. App icons (Android adaptive + iOS) generated from `assets/app_icon.png`; native splash on Android (incl. Android 12) and iOS uses `assets/logo.png` on `#F7F9FC` background. Removed misnamed `mipmap-anydpi-v26 copy` folder; proper adaptive icon XML now in `mipmap-anydpi-v26/`.

**Files touched:** `pubspec.yaml`, `assets/app_icon.png`, `assets/logo.png`, Android `res/` (mipmap, drawable, values-v31), iOS `LaunchImage.imageset`, `AppIcon.appiconset`

---

## 2026-05-27 — Real location search with Nominatim

**What changed:** Replaced demo place catalog and GPS-offset dropoffs with OpenStreetMap Nominatim geocoding. Both pickup and dropoff are searchable; GPS pickup is reverse-geocoded on sheet open. Quick chips use saved home/work (SharedPreferences) or airport Nominatim query.

**Architecture:** `features/home/shared/` geocoding layer (repository, Nominatim datasource, use cases) + `LocationSearchCubit` with debounce, cancel, offline guard.

**Removed:** `DemoPlace`, `DemoDestinations`, `demo_destinations_test.dart`

**Files touched:** `place_suggestion.dart`, `nominatim_remote_datasource.dart`, `geocoding_repository_impl.dart`, `saved_places_local_datasource.dart`, `location_search_cubit.dart`, `request_ride_sheet.dart`, `home_map_page.dart`, `home_destination_panel.dart`, `route_constants.dart`, `env_config.dart`, `injection_container.dart`, `en.json`, `ar.json`, `nominatim_place_model_test.dart`, `location_search_cubit_test.dart`

---

## 2026-05-27 — Randomized driver placement for live tracking

**What changed:** Driver GPS at tracking start is no longer taken from static catalog coords. Each trip gets a deterministic random start near pickup (seeded by trip id), kept away from the dropoff, with max ~8 min approach ETA. OSRM retries up to 4 times with closer placement if road ETA exceeds 8 min.

**Files touched:** `driver_placement.dart`, `route_service.dart`, `tracking_bloc.dart`, `demo_destinations.dart` (removed catalog GPS snap), `driver_placement_test.dart`, `tracking_bloc_test.dart`

---

## 2026-05-27 — Destination autocomplete on ride request sheet

**What changed:** The "Where to?" bottom sheet now shows searchable destination suggestions while typing. Continue is disabled until the user selects a place; coordinates come from the selected catalog entry.

**Catalog:** `DemoPlace` + 8 demo places in `DemoDestinations.places` with `searchPlaces()` filter.

**Files touched:** `demo_place.dart`, `demo_destinations.dart`, `request_ride_sheet.dart`, `en.json`, `ar.json`, `demo_destinations_test.dart`

---

## 2026-05-27 — Per-km pricing + two-phase live tracking

**What changed:** Ride fares are now distance-based (base + rate/km per tier). Live tracking uses a two-leg route (driver → pickup → dropoff) with distance-weighted progress and ETA.

**Pricing:** `PricingConfig` tier rates → `EstimateFareUseCase` → dynamic prices in `RideSelectionSheet` after OSRM quote.

**Tracking:** `RouteService.getTripRoutePlan()` concatenates approach + trip legs; `TrackingBloc` advances by distance at OSRM-derived speed; phase UI shows approach vs on-trip and remaining km.

**Tests:** `estimate_fare_usecase_test.dart`, extended `route_geometry_test.dart`, updated `tracking_bloc_test.dart`.

**Files touched:** `pricing_config.dart`, `estimate_fare_usecase.dart`, `route_service.dart`, `route_geometry.dart`, `tracking_bloc.dart`, `tracking_state.dart`, `tracking_bottom_sheet.dart`, `tracking_page.dart`, `ride_selection_sheet.dart`, `injection_container.dart`, translations

---

## 2026-05-27 — 12-hour clock (AM/PM) app-wide

**What changed:** All user-visible clock times now use 12-hour AM/PM format regardless of device 24-hour setting.

**Implementation:** `lib/core/utils/date_time_format.dart` with `formatAppClockTime`, `formatTripDate`, `formatAppDateTime`; chat message timestamps fixed from 24h `Hm()`; ride ETA uses shared formatter; `MaterialApp.builder` sets `alwaysUse24HourFormat: false`.

**Files touched:** `date_time_format.dart`, `app.dart`, `chat_message_bubble.dart`, `ride_option_card.dart`, `trip_widgets.dart`, `profile_page.dart`

---

## 2026-05-27 — Unified trip quote data (fare, km, driver, payment)

**What changed:** Ride selection quote fields now persist on `TripEntity` and display consistently across home, tracking, list, and detail.

**Fields added to TripEntity:** `distanceKm`, `etaMinutes`, `paymentMethodKey`, `rideTierKey`

**Flow:** `RideSelectionSheet` loads `RouteService` quote → passes selected tier price + route ETA/distance + payment into `RequestRideSubmitted` → Hive + mock API → `TripMetaRow` on cards/tracking/detail

**Other fixes:** Mock POST assigns drivers from `drivers.json`; wallet debits only for card payment; trip detail uses real driver rating/vehicle instead of hardcoded text.

**Files touched:** `trip_entity.dart`, `hive_adapters.dart`, `ride_selection_sheet.dart`, `trip_card.dart`, `tracking_bottom_sheet.dart`, `trip_detail_page.dart`, `mock_api_interceptor.dart`, `trips.json`, translations

---

## 2026-05-27 — Connected trip data flow (home, tracking, history)

**What changed:** Home ride request, live tracking, and trips list now share a single shell-scoped `TripListBloc` backed by Hive.

**Data flow:**

- `TripListBloc` registered as lazy singleton + provided in `app.dart`
- `TripListCacheSyncRequested` re-reads Hive without loading flash or mock force-refresh
- `notifyTripsCacheChanged()` wired from ride request, tracking completion, trip detail updates, FCM, and `SyncService`
- Trips tab switch triggers cache sync (mirrors notifications tab pattern)
- `TrackingBloc` persists `inProgress` on load and `completed` on animation finish (wallet + FCM)

**Files touched:** `app.dart`, `injection_container.dart`, `sync_service.dart`, `trip_list_bloc.dart`, `tracking_bloc.dart`, `map_bloc.dart`, `trip_detail_bloc.dart`, `main_shell_page.dart`, `trip_list_page.dart`

---

## 2026-05-27 — Trips list current trip card + history sections

**What changed:** Restructured the trips tab into pinned **Current Trip** and **Trip History** sections.

**UX:**

- Active trip (`requested`, `accepted`, `driverArrived`, `inProgress`) shown in `CurrentTripCard` with live status chip, optional driver row, and **Track Trip** button
- History list excludes the active trip; empty history hint when only a current trip exists
- Section headers use `current_trip` / `trip_history` localization keys (EN + AR)

**Domain / presentation:**

- `trip_extensions.dart` — `isCurrentTrip`, `partitionTrips()`
- `TripListLoaded.currentTrip` / `historyTrips` getters
- `CurrentTripCard` widget in `trip_list/presentation/widgets/`

**Tests:** `test/trip_partition_test.dart`

**Files touched:** `trip_list_page.dart`, `trip_list_state.dart`, `trip_card.dart`, `trip_extensions.dart`, `current_trip_card.dart`, `en.json`, `ar.json`

---

## 2026-05-27 — Driver profile screen

**What changed:** Added trip-scoped driver profile page with merged trip/mock driver data, chat/call actions, and ratings & reviews section.

**Ratings & reviews:**

- Mock data in `assets/mock/driver_reviews.json` served via `/drivers/:id/reviews`
- `DriverRatingSummaryCard` (average + star distribution bars) and `DriverReviewCard` list on profile page

**Screen / route:**

- `DriverProfilePage` at `/trips/:tripId/driver` — avatar, rating, vehicle, demo trip count, message/call buttons

**Navigation:**

- Trip detail driver card and tracking driver row (avatar/name) tap → driver profile

**Files touched:** `driver_profile/` sub-feature, `app_router.dart`, `route_names.dart`, `injection_container.dart`, `trip_detail_page.dart`, `tracking_driver_row.dart`, `en.json`, `ar.json`

---

## 2026-05-27 — Driver chat and call screens

**What changed:** Added in-app driver messaging and simulated voice call flows under the trips domain.

**Screens / routes:**

- `DriverChatPage` at `/trips/:tripId/chat` — message bubbles, send field, Hive-backed thread, demo driver auto-reply
- `DriverCallPage` at `/trips/:tripId/call` — connecting state, elapsed timer, mute/speaker/end controls (demo only)

**Navigation:**

- Trip detail and tracking driver row chat/call buttons push GoRouter routes (replacing `launchSms` / `launchPhoneCall`)

**Data / DI:**

- `chat_messages_box` Hive storage, `ChatRepository`, chat use cases, `DriverChatBloc`, `DriverCallBloc`

**Files touched:** `trips/shared/` chat layer, `driver_chat/`, `driver_call/`, `app_router.dart`, `route_names.dart`, `injection_container.dart`, `trip_detail_page.dart`, `tracking_driver_row.dart`, `en.json`, `ar.json`

---

## 2026-05-27 — Wire all buttons and icons

**What changed:** Replaced non-functional stub controls across main-shell tabs and trip/profile flows with working demo actions.

**UI / navigation:**

- Removed hamburger menu stubs on Home, Trips, Notifications, Profile; added `ShellAppBarLogo` leading widget
- Home/Trips AppBar avatars navigate to profile tab via `ProfileAvatarButton`

**Profile:**

- Wallet Top Up opens amount picker (50/100/200 EGP) → `ProfileWalletTopUpRequested`
- Avatar edit badge opens name editor → `AuthRepository.updateProfile` + `ProfileUpdateRequested`
- Order tiles open read-only detail bottom sheet

**Trips / ride flow:**

- Trip detail call/SMS use `launchPhoneCall` / `launchSms` when driver phone present; error state retry wired
- Ride selection payment/promo chips open picker sheet and promo dialog

**Files touched:** `shell_app_bar_logo.dart`, `profile_avatar_button.dart`, `phone_launcher.dart`, tab pages, `profile_page.dart`, `profile_bloc.dart`, `auth_repository*.dart`, `trip_detail_page.dart`, `ride_selection_sheet.dart`, `en.json`, `ar.json`

---

## 2026-05-27 — AI agent documentation surface

**What changed:** Added Technology 92–style agent infrastructure adapted for Nokta.

**Files created:**

- `AGENTS.md` (expanded canonical), `CLAUDE.md`, `CURSOR.md`, `CHANGELOG.md`
- `.agents/` — AGENTS.md shim, 7 rules, 22 skills (3 project-tuned + 19 official)
- `.cursor/rules/` — 7 scoped `.mdc` rules; `.cursor/skills/` — 3 project skills
- `.claude/commands/` — 8 slash commands + settings.json
- `.codex/AGENTS.md`, `.github/copilot-instructions.md`, `.github/workflows/docs.yml`
- `tech_readme_files/` — INDEX, ONBOARDING, CURRENT_STATUS, how-tos, ADRs, pitfalls, troubleshooting, glossary
- `scripts/docs/` — ai_ignore_template, sync/check scripts + root shims
- `skills-lock.json`, `.markdownlint-cli2.jsonc`

**Key decisions:**

- easy_localization JSON instead of ARB (matches existing codebase)
- Sub-feature `shared/` + presentation layout documented as canonical
- Official Flutter/Dart skills copied from tech92 lockfile (same upstream hashes)

**Verification:**

- Run `.\scripts\sync_ai_ignores.ps1`
- Run `.\scripts\check_docs_freshness.ps1`
- Run `.\scripts\check_skills_drift.ps1`
