# 01 — Folder Structure

```
lib/
├── main.dart, app.dart, injection_container.dart
├── config/          # routes, theme, EnvConfig
├── core/            # api, cache, network, sync, map utils, widgets
├── shared/          # spacing, buttons, inputs, branding
└── features/
    ├── settings/
    ├── auth/        # shared/ + splash, onboarding, auth_select, login, register, forgot_password
    ├── home/        # main_shell, map_view, ride_request
    ├── trips/       # shared/ + trip_list, trip_detail, tracking
    ├── notifications/
    └── profile/     # shared/ + profile_view, orders

assets/
├── translations/    # en.json, ar.json
├── mock/            # demo API JSON
└── lottie/

test/                # bloc + unit tests
tech_readme_files/   # extended docs
.agents/skills/      # agent skills
```

See [`AGENTS.md`](../AGENTS.md) § Feature Architecture for the shared/ + sub-feature pattern.
