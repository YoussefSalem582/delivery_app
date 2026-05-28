# Onboarding — Nokta

> [INDEX](INDEX.md) > Onboarding

## Day 1

1. Read [`README.md`](../README.md) and run `flutter pub get` + `flutter run`
2. Read [`AGENTS.md`](../AGENTS.md) — canonical conventions
3. Skim [02_architecture.md](02_architecture.md) — folder layout + offline flow
4. Try demo flow: login → search pickup/dropoff (Nominatim) → request ride → two-phase tracking → profile sync

## Key paths

| Need | Location |
|------|----------|
| Routes | `lib/config/routes/` |
| DI | `lib/injection_container.dart` |
| Theme tokens | `lib/config/theme/` |
| Maps | `lib/core/widgets/delivery_map.dart`, `lib/core/utils/map_config.dart` |
| Geocoding | `lib/features/home/shared/` (Nominatim), `location_search_cubit.dart` |
| Routing / tracking | `lib/core/network/route_service.dart`, `lib/core/utils/driver_placement.dart` |
| Pricing | `lib/features/trips/shared/domain/usecases/estimate_fare_usecase.dart` |
| Branding assets | `assets/logo.svg`, `assets/logo.png`, `assets/app_icon.png`; regen via `pubspec.yaml` icon/splash config |
| Translations | `assets/translations/en.json`, `ar.json` |
| Mock API | `assets/mock/`, `lib/core/network/mock_api_interceptor.dart` |
| Hive boxes | `lib/core/cache/` |

## Doc hygiene scripts

| Command | Purpose |
|---------|---------|
| `.\scripts\sync_ai_ignores.ps1` | Regenerate AI ignore files |
| `.\scripts\check_docs_freshness.ps1` | Version sync check |
| `.\scripts\check_skills_drift.ps1` | Skills lockfile check |
| `npx skills update` | Refresh official Flutter/Dart skills |

## Do not

- Hardcode colors, spacing, routes, or user-facing strings
- Call repositories from BLoCs (use use cases)
- Port Technology 92 attendance/KPI features — keep ride-hailing domain
