---
description: "Clean Architecture — shared/ + sub-feature layout"
globs: "lib/features/**/*.dart"
alwaysApply: false
---

# Feature Architecture

Nokta uses `features/<domain>/shared/` (data + domain) + sub-features (presentation):

```
features/<domain>/
├── shared/
│   ├── data/       # datasources, models, repositories
│   └── domain/     # entities, repository contracts, usecases
└── <sub_feature>/  # e.g. trip_list, tracking, login
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

## Dependency Rule

Presentation → Domain ← Data. Domain has zero Flutter imports.

## Domain

- Entities: `Equatable`, no serialization
- Repositories: abstract, `Either<Failure, T>`
- Use cases: extend `UseCase<ReturnType, Params>`

## Data

- Models extend entities + `fromJson`/`toJson`
- Remote datasources use `ApiClient` (or mock interceptor in demo)
- Repository impls map exceptions → `Failure`

## Presentation

- BLoC calls use cases only
- Register BLoCs as `registerFactory` in `injection_container.dart`
