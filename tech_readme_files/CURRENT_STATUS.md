# Nokta — Current Project Status

> [INDEX](INDEX.md) > Current Status
>
> **Last Updated:** May 27, 2026 — Real Nominatim location search for pickup and dropoff.

> **Version:** `1.0.0+1`
> **Flutter:** 3.16+ (SDK ^3.12.0)
> **Status:** ✅ MVP template complete | 📚 Agent docs initialized | 🚧 Production backend TBD

## Executive Summary

Nokta is a Flutter ride-hailing / delivery MVP template with Clean Architecture + BLoC, offline-first Hive cache, live map tracking, and bilingual EN/AR support.

### Key Highlights

- ✅ **6 feature domains** — auth, home, trips, notifications, profile, settings
- ✅ **Sub-feature layout** — `shared/` + presentation sub-folders per screen flow
- ✅ **Offline-first** — Hive cache, pending sync queue, reconnect sync
- ✅ **Maps** — flutter_map + OSRM + tile disk cache + live tracking
- ✅ **i18n** — easy_localization JSON (EN + AR, RTL)
- ✅ **Observability** — Talker (Dio, BLoC, in-app console)
- ✅ **Agent docs** — AGENTS.md, 22 skills, Cursor/Claude/Codex/Copilot shims

## Feature Status

| Feature | Status |
|---------|--------|
| Auth (splash, onboarding, login, register) | ✅ Demo complete |
| Home / map / ride request | ✅ Demo complete (Nominatim geocoding for pickup + dropoff, saved home/work chips, OSRM routing, per-km fare, payment/promo pickers) |
| Trips (list, detail, tracking) | ✅ Demo complete (randomized driver near pickup ≤8 min approach, two-phase tracking, connected cache sync, current trip card, driver profile, chat + call) |
| Notifications | ✅ Demo complete |
| Profile / orders | ✅ Demo complete (wallet top-up, edit name, order details) |
| Settings (theme, locale) | ✅ Complete |
| Real backend integration | 🚧 Mock API only |
| Production auth (secure storage) | 🚧 Planned |
| Payments / wallet (real) | 🚧 Demo top-up only (Hive-local) |

## Testing

- `flutter test` — bloc tests (TripList, Order, Tracking), RouteService unit tests, fare estimate tests, route geometry tests, driver placement tests, demo destination search tests, sync dedupe tests, trip partition tests

## Documentation

| Doc | Status |
|-----|--------|
| AGENTS.md (canonical) | ✅ |
| tech_readme_files/ | ✅ Initial set |
| CHANGELOG.md | ✅ |
| CI docs workflow | ✅ |
