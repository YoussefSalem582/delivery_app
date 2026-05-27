# Nokta — Current Project Status

> [INDEX](INDEX.md) > Current Status
>
> **Last Updated:** May 27, 2026 — Trips list shows pinned current trip card with Track CTA and trip history section.

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
| Home / map / ride request | ✅ Demo complete (payment/promo pickers wired) |
| Trips (list, detail, tracking) | ✅ Demo complete (current trip card + history sections, driver profile, in-app chat + simulated call) |
| Notifications | ✅ Demo complete |
| Profile / orders | ✅ Demo complete (wallet top-up, edit name, order details) |
| Settings (theme, locale) | ✅ Complete |
| Real backend integration | 🚧 Mock API only |
| Production auth (secure storage) | 🚧 Planned |
| Payments / wallet (real) | 🚧 Demo top-up only (Hive-local) |

## Testing

- `flutter test` — bloc tests (TripList, Order), RouteService unit tests, sync dedupe tests, trip partition tests

## Documentation

| Doc | Status |
|-----|--------|
| AGENTS.md (canonical) | ✅ |
| tech_readme_files/ | ✅ Initial set |
| CHANGELOG.md | ✅ |
| CI docs workflow | ✅ |
