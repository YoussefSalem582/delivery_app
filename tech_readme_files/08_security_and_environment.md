# 08 — Security and Environment

## Secrets

- Pass via `--dart-define` at build time
- Read through `EnvConfig` in `lib/config/environment/`
- Never commit `.env` with real keys

## Demo auth

Current MVP stores session in SharedPreferences/Hive — acceptable for demo only.

## Production checklist

- [ ] `FlutterSecureStorage` for tokens
- [ ] Centralize keys in `storage_keys.dart`
- [ ] Obfuscate release builds
- [ ] Restrict mock interceptor to debug builds

## Firebase

Optional — FCM falls back to simulated notifications without Firebase config.
