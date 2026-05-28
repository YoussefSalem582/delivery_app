---
description: "API integration — ApiClient, mock interceptor, offline queue"
globs: "lib/core/api/**,lib/**/datasources/**,lib/**/repositories/**"
alwaysApply: false
---

# API Integration

## Flow

1. Add HTTP call to remote data source (`ApiClient.get/post/...`)
2. Parse JSON into model (`fromJson`)
3. Domain repository contract → `Either<Failure, T>`
4. Repository impl with try/catch → Failure mapping
5. Use case → BLoC/Cubit → DI registration

## Demo mode

`MockApiInterceptor` serves JSON from `assets/mock/` — no real backend required for trips, orders, auth, notifications.

## External APIs (real HTTP)

| Service | Layer | Notes |
|---------|-------|-------|
| Nominatim | `home/shared/data/datasources/nominatim_remote_datasource.dart` | Geocoding search + reverse; offline guard in UI; production needs own instance |
| OSRM | `lib/core/network/route_service.dart` | Route polylines; dedupe, timeout, cache, straight-line fallback |

Do not mock these via `MockApiInterceptor` — use repository pattern with connectivity checks.

## Offline

- Reads: Hive cache + 5-minute TTL metadata; stale-while-revalidate in list BLoCs
- Writes: enqueue via `PendingSyncLocalDataSource`; drain with `SyncService.syncAll()`

## Talker

Dio requests logged via `TalkerDioLogger` (see `talker_setup.dart`).
