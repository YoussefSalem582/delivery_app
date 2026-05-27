# 02 — Architecture

## Clean Architecture + BLoC

```
Presentation (BLoC → Pages → Widgets)
     ↓
Domain (UseCases → Repository contracts → Entities)
     ↑
Data (Repository impls → DataSources → ApiClient / Hive)
```

## Offline-First (reads)

1. BLoC requests data via use case
2. Repository checks Hive cache + cache metadata TTL (5 min)
3. If fresh → return cache
4. If stale → return cache, refresh in background
5. If expired / empty → fetch remote (or mock)

## Offline-First (writes)

1. BLoC dispatches mutation use case
2. If offline → enqueue in `pending_sync` box
3. On reconnect → `SyncService.syncAll()` drains queue

## Maps stack

`DeliveryMap` → flutter_map → OSRM (`RouteService`) → tile cache

See [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) for common map/offline issues.
