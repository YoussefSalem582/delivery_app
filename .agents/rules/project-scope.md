---
description: "Project scope — Nokta Flutter ride-hailing MVP"
alwaysApply: true
---

# Project Scope

**Only work on `delivery_app/` (Nokta Flutter app).**

## Project Overview

- **App**: Nokta — ride-hailing / delivery MVP template
- **Architecture**: Clean Architecture + BLoC; `features/<domain>/shared/` + sub-features
- **State**: `flutter_bloc` (BLoC for features, Cubit for settings/connectivity)
- **Routing**: GoRouter with `RouteNames`
- **DI**: GetIt (`injection_container.dart`)
- **Networking**: Dio + `MockApiInterceptor` (demo JSON)
- **Storage**: Hive (trips, orders, user, notifications, routes) + SharedPreferences
- **Localization**: `easy_localization` JSON (EN + AR)
- **Maps**: flutter_map + OSRM + tile cache
- **Offline**: ConnectivityCubit + SyncService + pending sync queue

## Entry Points

| File | Purpose |
|------|---------|
| `lib/main.dart` | Firebase, Hive, DI, EasyLocalization init |
| `lib/app.dart` | MaterialApp.router + providers |
| `lib/injection_container.dart` | GetIt registration |
