# Copilot Instructions — Shim

> **Canonical conventions live in [`../AGENTS.md`](../AGENTS.md).**
> Read that file first. This file contains **only Copilot-specific runtime guidance**.

## Project scope

- Modify files **only** inside `delivery_app/`.

## Copilot-specific behavior

### Inline completion

- **Never invent** raw `Color(0xFF…)`, `EdgeInsets.all(N)`, hardcoded route strings, or hardcoded API paths. Use `AppColors`, `AppSpacing`, `RouteNames`.
- **Never** suggest user-facing string literals. Suggest `'some_key'.tr()` and add keys to both `assets/translations/en.json` and `ar.json`.
- When completing inside a feature folder, respect `shared/` (data + domain) vs sub-feature `presentation/`. No Flutter imports in `domain/`.

### Copilot Chat conventions

- For architecture questions, read `tech_readme_files/decisions/` or relevant `tech_readme_files/0X_*.md` docs.
- For tests: prefer `mocktail` over `mockito`.
- For new endpoints/features: defer to `.agents/skills/` (`add-api`, `add-feature`, `add-language`).

### Comment-trigger generation

- New BLoC → event/state pattern from canonical doc § State Management.
- New Cubit (e.g. search) → simpler state class, debounce/cancel for async.
- New repository method → `Either<Failure, T>` + exception mapping.
- New screen → `RouteNames` + `app_router.dart` entry.
- Offline writes → pending sync queue via `SyncService`.
- Geocoding / place search → `home/shared/` repository + `LocationSearchCubit`; never reintroduce demo place catalog.
- Fare / pricing → `EstimateFareUseCase` + OSRM distance; branding → `pubspec.yaml` icon/splash generators.

### Windows / PowerShell

Suggest `.ps1` scripts under `scripts/`, not `.sh`. Use `;` instead of `&&`.

## Where to look

| Need | Location |
|------|----------|
| Project conventions | [`../AGENTS.md`](../AGENTS.md) |
| Skills | [`../.agents/skills/`](../.agents/skills/) |
| Doc index | [`../tech_readme_files/INDEX.md`](../tech_readme_files/INDEX.md) |
