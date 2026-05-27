# 10 — Testing

## Run

```bash
flutter test
```

## Conventions

- **Unit tests**: pure logic, datasources with mocks — `package:test` + `mocktail`
- **Bloc tests**: `bloc_test` package — see `test/` for TripListBloc, OrderBloc examples
- **Widget tests**: prefer skill `flutter-add-widget-test`

## Coverage gaps

- Widget tests for key screens (home, tracking, auth)
- Integration tests for offline sync flow

## Collect coverage

Use skill `dart-collect-coverage` or:

```bash
flutter test --coverage
```
