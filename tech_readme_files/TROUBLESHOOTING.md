# Troubleshooting

## Maps not loading

- Check internet — OpenStreetMap tiles require network on first load
- Verify `map_config.dart` tile URL
- Tile cache: `lib/core/utils/map_tile_cache.dart` — clear app data if stale

## Route polyline is a straight line

- OSRM demo server may be unreachable — `RouteService` falls back to straight line
- Offline: expected behavior; uses cached route or straight line

## Trips not syncing after offline

- Confirm `ConnectivityCubit` shows online
- Profile → sync or wait for `NetworkStatus` reconnect handler
- Check Talker logs (long-press profile avatar) for `SyncService` errors

## Translations missing / key shown raw

- Key must exist in **both** `assets/translations/en.json` and `ar.json`
- Hot restart after JSON edits (easy_localization loads at startup)

## `flutter analyze` failures after feature scaffold

- Run from repo root
- Ensure new files are imported in DI and routes

## Docs CI failing

```powershell
.\scripts\check_docs_freshness.ps1   # pubspec version in README, CHANGELOG, CURRENT_STATUS
.\scripts\sync_ai_ignores.ps1 -Check
.\scripts\check_skills_drift.ps1
```

## Skills drift

```bash
npx skills update
.\scripts\check_skills_drift.ps1
```
