---
name: add-feature
description: Scaffold a new Clean Architecture feature with shared/ + sub-feature layers, DI, routing, and translations. Use when creating a new feature module.
---

# Add New Feature

Scaffold a Nokta feature with `shared/` (data + domain) and sub-feature presentation folders.

## When to Use

- User asks to create a new feature, screen, or module
- User says "add feature", "create feature", "new feature"

## Instructions

Reference `tech_readme_files/03_how_to_add_new_feature.md`.

### Step 1 — Folder Structure

```
lib/features/<domain>/
├── shared/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   └── repositories/
│   └── domain/
│       ├── entities/
│       ├── repositories/
│       └── usecases/
└── <sub_feature>/
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

### Step 2–7 — Domain + Data (in `shared/`)

- Entity: pure Dart + Equatable, no `fromJson`
- Repository contract: `Either<Failure, T>`
- Use cases: extend `UseCase<ReturnType, Params>`
- Model: extends entity + `fromJson`/`toJson`
- Remote datasource: `ApiClient` or Hive local datasource
- Repository impl: exception → failure mapping

### Step 8–10 — BLoC (in sub-feature `presentation/bloc/`)

- Separate `_event.dart`, `_state.dart`, `_bloc.dart`
- Inject use cases; use `result.fold()`
- For reads: respect Hive cache + TTL via existing cache datasources
- For writes: check connectivity; queue via pending sync when offline

### Step 11 — Pages & Widgets

Use `AppColors`, `AppSpacing`, shared widgets, `'key'.tr()` for strings.

### Step 12 — DI

In `injection_container.dart`: lazy singletons for data/domain; `registerFactory` for BLoC.

### Step 13 — Route & Translations

- Add to `lib/config/routes/route_names.dart` and `app_router.dart`
- Add keys to `assets/translations/en.json` and `ar.json`

## Post-Completion Checklist

- [ ] shared/ + sub-feature layers created
- [ ] DI registered
- [ ] Route added with `RouteNames`
- [ ] EN + AR translation keys added
- [ ] CHANGELOG.md, DOCUMENTATION_UPDATE_SUMMARY.md, CURRENT_STATUS.md updated
