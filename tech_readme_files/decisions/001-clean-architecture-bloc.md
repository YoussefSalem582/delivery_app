# ADR 001: Clean Architecture + BLoC

**Status:** Accepted

## Context

Need scalable structure for ride-hailing features with testable business logic.

## Decision

- Clean Architecture: presentation → domain ← data
- BLoCs call use cases returning `Either<Failure, T>`
- Sub-feature folders: `shared/` + presentation per screen flow

## Consequences

- More boilerplate than Provider-only apps
- Clear boundaries for swapping mock → real API
