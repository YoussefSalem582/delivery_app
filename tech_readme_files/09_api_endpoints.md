# 09 — API Endpoints (Demo)

Demo mode uses `MockApiInterceptor` — not a live REST catalog.

| Area | Mock source | Feature |
|------|-------------|---------|
| Auth | In-memory / local | `auth/shared/` |
| Trips | `assets/mock/trips.json` | `trips/shared/` |
| Orders | Remote + local cache | `profile/shared/` |
| Notifications | `assets/mock/notifications.json` | `notifications/shared/` |
| Routing | OSRM public demo | `RouteService` |

When wiring production, document endpoints here with method, path, and app status columns.
