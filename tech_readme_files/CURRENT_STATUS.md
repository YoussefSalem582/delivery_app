# Nokta — Current Project Status

> [INDEX](INDEX.md) > Current Status
>
> **Last Updated:** May 28, 2026 — Skills lock LF alignment for Linux CI drift check.
> **Version:** `1.0.0+1`
> **Flutter:** 3.16+ (SDK ^3.12.0)
> **Status:** ✅ MVP template complete | ✅ Dual-mode driver demo | ✅ Web client demo | 🚧 Production backend TBD

## Executive Summary

Nokta is a Flutter ride-hailing / delivery MVP template with Clean Architecture + BLoC, offline-first Hive cache, live map tracking, and bilingual EN/AR support.

### Key Highlights

- ✅ **6 feature domains** — auth, home, trips, notifications, profile, settings (+ driver mode)
- ✅ **Sub-feature layout** — `shared/` + presentation sub-folders per screen flow
- ✅ **Offline-first** — Hive cache, pending sync queue, reconnect sync
- ✅ **Maps** — flutter_map + OSRM + tile disk cache + live tracking
- ✅ **i18n** — easy_localization JSON (EN + AR, RTL)
- ✅ **Observability** — Talker (Dio, BLoC, in-app console)
- ✅ **Agent docs** — AGENTS.md, 22 skills, Cursor/Claude/Codex/Copilot shims
- ✅ **Native branding** — Android/iOS/Web launcher icons from `assets/app_icon.png` via `flutter_launcher_icons`; native splash + in-app wordmark use `assets/logo.png` (light) / `assets/logo_light.png` (dark)
- ✅ **Web client demo** — shareable link with device frame (`device_preview`); auto-deploy to GitHub Pages from `main`

## Client demo (web)

| Item | Detail |
|------|--------|
| **Live URL** | https://youssefsalem582.github.io/Nokta-Delivery-App/ (deploys from `main` via GitHub Actions) |
| **Deploy trigger** | Push to `main` or manual **Deploy Web Demo** workflow run |
| **Local preview** | `flutter run -d chrome` |
| **Release build** | `flutter build web --release --base-href /Nokta-Delivery-App/` |
| **Deploy** | Push to `main` triggers `.github/workflows/deploy-web-demo.yml` |
| **Pages setup** | Settings → Pages → Source: **GitHub Actions** |

**Web demo limits:** push notifications simulated only; no Workmanager background sync; geocoding uses Photon (not Nominatim); open-in-maps opens Google Maps in a new tab.

## Feature Status

| Feature | Status |
|---------|--------|
| Auth (splash, onboarding, login, register) | ✅ Demo complete |
| Home / map / ride request | ✅ Demo complete (Nominatim geocoding for pickup + dropoff, saved home/work chips, OSRM routing, per-km fare, payment/promo pickers) |
| Trips (list, detail, tracking) | ✅ Demo complete (randomized driver near pickup ≤8 min approach, two-phase tracking, connected cache sync, current trip card, driver profile, chat + call) |
| Notifications | ✅ Demo complete (typed inbox, All/Trip/Messages/Calls + Unread filters, live trip status chip, chat/call notifications, swipe delete + undo, mark-all-read, nav badge) |
| Profile / orders | ✅ Demo complete (wallet top-up, edit name, order details) |
| Settings (theme, locale, driver mode) | ✅ Complete (shared `AppModeSwitchTile`, `LogoutButton`, `performAppLogout`) |
| Driver mode (shell, offers, jobs, active trip) | ✅ Demo complete (offer map preview with passenger sheet; active trip uses shared `TrackingBloc` / `LiveTrackingPage`) |
| Web client demo (Device Preview + GitHub Pages) | ✅ Merged to `main`; deploys via GitHub Actions on push |
| Real backend integration | 🚧 Mock API only |
| Production auth (secure storage) | 🚧 Planned |
| Payments / wallet (real) | 🚧 Demo top-up only (Hive-local) |

## Testing

- `flutter test` — 72 tests including `GetRiderForTripUseCase`, `DriverOfferPreviewCubit`, `TrackingBloc` driver rider fields, `SwitchAppModeUseCase`, entity Hive round-trip, trip query filters

## Documentation

| Doc | Status |
|-----|--------|
| AGENTS.md (canonical) | ✅ |
| tech_readme_files/ | ✅ Initial set |
| CHANGELOG.md | ✅ |
| CI docs workflow | ✅ |
