# ADR: Dual-mode passenger/driver architecture

**Date:** 2026-05-28  
**Status:** Accepted

## Context

Nokta needs one app where users can ride and optionally become drivers without a separate login.

## Decision

- Extend `UserEntity` with `isDriverRegistered` + embedded `DriverProfileEntity` (one-time onboarding).
- Persist UI mode in `AppModeCubit` (`passenger` | `driver`) via SharedPreferences.
- Use a single `trips_box`; rider and driver UIs filter by `riderId` / `driverId`.
- Fan out cache updates through `AppDataCoordinator` to `TripListBloc`, `DriverJobsBloc`, `DriverOffersBloc`, and `NotificationBloc`.
- Mock backend uses `MockApiStore` (mutable in-memory state) instead of static JSON responses after mutations.

## Consequences

- Same device can demo rider and driver flows by mode toggle (different trips).
- Rider tracking subscribes to trip poll when `driverId` is set; legacy simulation remains for trips without assigned drivers.
- Production swap: implement `/v1/driver/*` and set `USE_MOCK_DRIVER_API=false`.
