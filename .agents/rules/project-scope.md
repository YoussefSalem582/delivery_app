---
description: "Project scope — Nokta Flutter ride-hailing MVP"
alwaysApply: true
---

# Project Scope

**Only work on `delivery_app/` (Nokta Flutter app).**

## Project Overview

- **App**: Nokta — ride-hailing / delivery MVP template (`1.0.0+1`)
- **Architecture**: Clean Architecture + BLoC; `features/<domain>/shared/` + sub-features
- **State**: `flutter_bloc` (BLoC for features, Cubit for settings/connectivity/search)
- **Routing**: GoRouter with `RouteNames`
- **DI**: GetIt (`injection_container.dart`)
- **Networking**: Dio + `MockApiInterceptor` (demo JSON); Nominatim + OSRM via real HTTP
- **Storage**: Hive (trips, orders, user, notifications, routes) + SharedPreferences (settings, saved home/work)
- **Localization**: `easy_localization` JSON (EN + AR, RTL)
- **Geocoding**: Nominatim autocomplete + reverse geocode (`home/shared/`)
- **Maps**: flutter_map + OSRM + tile cache; two-phase live tracking
- **Pricing**: Per-km fares by tier via `EstimateFareUseCase`
- **Offline**: ConnectivityCubit + SyncService + pending sync queue
- **Branding**: Native icons/splash from `assets/app_icon.png` / `assets/logo.png`; in-app `assets/logo.svg`

## Entry Points

| File | Purpose |
|------|---------|
| `lib/main.dart` | Firebase, Hive, DI, EasyLocalization init |
| `lib/app.dart` | MaterialApp.router + providers |
| `lib/injection_container.dart` | GetIt registration |
| `AGENTS.md` | Canonical agent conventions — read before multi-file edits |
