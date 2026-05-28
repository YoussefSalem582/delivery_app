# Agent Instructions — Generic Shim

> **Canonical conventions live in [`../AGENTS.md`](../AGENTS.md).** Read it first.
> This file is a thin shim for generic agents reading from `.agents/`. It contains only the **skill catalog pointer** + folder map.

## Scope

- Edit files **only** inside `delivery_app/` (this repo).

## Current feature snapshot (see canonical doc for details)

- Nominatim geocoding in `home/shared/` + `LocationSearchCubit`
- Per-km pricing via `EstimateFareUseCase`; two-phase tracking via `TrackingBloc`
- Native branding: `flutter_launcher_icons` + `flutter_native_splash` in `pubspec.yaml`
- Live status: [`../tech_readme_files/CURRENT_STATUS.md`](../tech_readme_files/CURRENT_STATUS.md)

## Skills (in this directory)

All skill prompts live in [`./skills/`](./skills/) in universal SKILL.md format. **22 skills total**:

- **3 project-tuned** (prefer over official ones for overlapping workflows):
  - `add-feature` — Scaffold shared/ + sub-feature Clean Architecture, DI, routing, i18n
  - `add-api` — Wire endpoint through `ApiClient`, Hive cache, pending sync queue
  - `add-language` — Add/update strings in `assets/translations/en.json` + `ar.json`
- **19 official** Flutter + Dart skills from `npx skills add` — see [`../AGENTS.md`](../AGENTS.md) § Available Skills.

### Updating official skills

```bash
npx skills update
```

SHA-256 hashes tracked in [`../skills-lock.json`](../skills-lock.json); verified by `scripts/check_skills_drift.ps1`.

## Where to look

| Need | File |
|------|------|
| Project overview, architecture, tokens, BLoC, API, offline, security | [`../AGENTS.md`](../AGENTS.md) |
| Onboarding & doc-map | [`../tech_readme_files/INDEX.md`](../tech_readme_files/INDEX.md) |
| Troubleshooting | [`../tech_readme_files/TROUBLESHOOTING.md`](../tech_readme_files/TROUBLESHOOTING.md) |
| Common pitfalls | [`../tech_readme_files/COMMON_PITFALLS.md`](../tech_readme_files/COMMON_PITFALLS.md) |
| Architecture decisions | [`../tech_readme_files/decisions/`](../tech_readme_files/decisions/) |
