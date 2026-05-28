# 09 — API Endpoints (Demo + Driver Contract)

Demo mode uses `MockApiInterceptor` with in-memory state seeded from JSON. Production driver endpoints are documented below for Phase 5 swap via `EnvConfig.useMockDriverApi`.

## Mock (current)

| Method | Path | Behavior |
|--------|------|----------|
| GET | `/profile` | User profile from `MockApiStore` |
| POST | `/driver/register` | One-time driver onboarding; upserts user + drivers catalog |
| GET | `/driver/profile` | Profile with optional `driverProfile` |
| PATCH | `/driver/availability` | `offline` / `online` / `onTrip` |
| GET | `/driver/offers` | Open `requested` trips where `riderId != currentUser` |
| POST | `/driver/offers/:id/accept` | Sets `driverId`, denormalized driver fields, `accepted` |
| POST | `/driver/offers/:id/decline` | Removes from offer pool |
| PATCH | `/driver/trips/:id/status` | Driver-owned status transitions |
| PATCH | `/driver/trips/:id/location` | Updates `driverLat` / `driverLng` on trip |
| POST | `/trips/request` | Creates `requested` trip with `riderId` (no auto-assign) |
| GET | `/trips` | All trips in shared store |

## Production contract (planned)

| Method | Path | Notes |
|--------|------|-------|
| POST | `/v1/driver/register` | Idempotent; 409 if already registered |
| GET | `/v1/driver/profile` | Server `isDriverRegistered` |
| PATCH | `/v1/driver/availability` | Server validates driver role |
| GET | `/v1/driver/offers` | Poll or WebSocket in production |
| POST | `/v1/driver/offers/{id}/accept` | |
| POST | `/v1/driver/offers/{id}/decline` | |
| PATCH | `/v1/driver/trips/{id}/status` | Server is source of truth |
| POST | `/v1/driver/location` | Stream / batch |

Toggle mock vs real: `--dart-define=USE_MOCK_DRIVER_API=false` (`EnvConfig.useMockDriverApi`).
