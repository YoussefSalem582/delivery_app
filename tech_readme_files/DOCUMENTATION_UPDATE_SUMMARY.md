# Documentation Update Summary

> Rolling log of documentation changes. Newest entries first.

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
