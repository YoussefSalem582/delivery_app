---
description: "Security — secrets, EnvConfig, production auth"
alwaysApply: false
---

# Security

- Never hardcode API URLs, tokens, or keys in Dart source
- Use `--dart-define` + `EnvConfig` for secrets when wiring production
- Demo auth uses SharedPreferences/Hive — migrate to `FlutterSecureStorage` for production tokens
- Storage keys in `lib/core/constants/storage_keys.dart`
- See `tech_readme_files/08_security_and_environment.md`
