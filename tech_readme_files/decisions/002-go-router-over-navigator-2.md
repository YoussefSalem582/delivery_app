# ADR 002: GoRouter over Navigator 2.0

**Status:** Accepted

## Decision

Use `go_router` with `RouteNames` constants, `StatefulShellRoute` for tab shell, auth redirects in `app_router.dart`.

## Consequences

- Deep links to trip detail / tracking
- Centralized redirect logic
