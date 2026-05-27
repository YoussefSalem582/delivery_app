# Glossary

| Term | Definition |
|------|------------|
| **Nokta** | App display name; ride-hailing / delivery MVP |
| **shared/** | Feature-level data + domain layer under `features/<domain>/shared/` |
| **Sub-feature** | Presentation-only folder (e.g. `trip_list/`, `tracking/`) |
| **UseCase** | Domain operation class; BLoCs call these, not repositories |
| **Either** | dartz `Either<Failure, T>` for error handling |
| **Hive box** | Local NoSQL store — trips, orders, user, notifications, routes |
| **Pending sync** | Queue of offline trip mutations drained by `SyncService` |
| **MockApiInterceptor** | Dio interceptor serving demo JSON from `assets/mock/` |
| **RouteService** | OSRM client + memory/disk route cache |
| **DeliveryMap** | Shared flutter_map widget for home + tracking |
| **Talker** | In-app + console logging for Dio, BLoC, errors |
| **skills-lock.json** | SHA-256 hashes for official skills from `npx skills add` |
| **Shim** | Thin per-tool doc (CLAUDE.md, CURSOR.md) pointing to AGENTS.md |
