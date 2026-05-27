# ADR 003: Offline-First with Hive

**Status:** Accepted

## Decision

- Hive boxes for trips, orders, user, notifications, routes
- 5-minute cache metadata TTL
- Pending sync queue for trip mutations
- `SyncService.syncAll()` on reconnect

## Consequences

- Demo works without backend
- Production needs conflict resolution strategy later
