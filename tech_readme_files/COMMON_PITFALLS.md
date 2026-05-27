# Common Pitfalls

## Don't hardcode design tokens

❌ `Color(0xFF0050CB)`, `EdgeInsets.all(16)`
✅ `AppColors.primary`, `AppSpacing.md`

## Don't hardcode strings

❌ `Text('Request Ride')`
✅ `Text('request_ride'.tr())` + keys in `en.json` and `ar.json`

## Don't call repositories from BLoCs

❌ `repository.getTrips()` inside bloc
✅ Inject `GetTripsUseCase`, call use case, `result.fold(...)`

## Don't hardcode routes

❌ `context.go('/trips/123')`
✅ Use `RouteNames` + named routes in `app_router.dart`

## Don't skip offline writes

Trip creates/status updates should enqueue when offline via pending sync — see `SyncService`.

## Don't port tech92 domain features

No attendance, KPI, Live Activity, or workforce-management patterns — keep maps, trips, FCM, Hive ride-hailing domain.

## Don't edit official skills in place

Skills tracked in `skills-lock.json` — run `npx skills update` instead.
