# 04 — How to Add a New API

Follow skill [`add-api`](../.agents/skills/add-api/SKILL.md).

## Demo (mock) mode

1. Add JSON fixture under `assets/mock/`
2. Register path in `MockApiInterceptor`
3. Parse in remote datasource → model → repository → use case → BLoC

## Production mode

1. Configure `EnvConfig.baseUrl` via `--dart-define`
2. Add Dio call in remote datasource via `ApiClient`
3. Map errors to `Failure` types in repository impl
4. For offline writes: pending sync queue pattern from trips feature

## Reference implementation

`features/trips/shared/data/datasources/trip_remote_datasource.dart`
