# Claude Code Instructions — Shim

> **Canonical conventions live in [`AGENTS.md`](AGENTS.md).** Read it first.
> This file contains **only Claude-Code-specific runtime guidance** (tool-use rules, response style, slash-commands, approved commands). Architecture, design tokens, BLoC, API, offline-first, security, and the full skill catalog all live in the canonical doc.

## Response Guidelines

- Be concise — lead with the action or answer, skip preamble.
- Do not summarize what you just did; the diff speaks for itself.
- Reference files with relative paths (e.g., `lib/core/api/api_client.dart`).
- Ask before creating new files that aren't required by the task.
- One task at a time — complete it fully before moving on.
- After every meaningful change: update `CHANGELOG.md`, `tech_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, and `tech_readme_files/CURRENT_STATUS.md` (per canonical doc § Mandatory Documentation).

## Environment

- **Platform**: Windows 11 — use PowerShell syntax in Bash commands, not Unix shell.
- **Shell scripts**: Use `.ps1` equivalents (`scripts/sync_ai_ignores.ps1`, `scripts/check_docs_freshness.ps1`, `scripts/check_skills_drift.ps1`).
- **Flutter**: SDK on PATH; run via `flutter <command>`.
- **Approved commands** (no prompt needed):
  - Build / codegen: `flutter pub get`, `flutter analyze`, `flutter test`, `dart format`, `dart run build_runner build`
  - Doc tooling: `.\scripts\sync_ai_ignores.ps1`, `.\scripts\sync_ai_ignores.ps1 -Check`, `.\scripts\check_docs_freshness.ps1`, `.\scripts\check_skills_drift.ps1`
  - Skills sync: `npx skills update`, `npx skills check`

## Tool-use rules

- **Read before edit**: always read a file before modifying it.
- **Prefer targeted edits** over full rewrites unless warranted.
- **Never bypass design tokens**: use `AppColors`, `AppSpacing`, etc.
- **Never hardcode user-facing strings**: pipe through `'key'.tr()` and add to both `assets/translations/en.json` + `ar.json`.
- **Bash on Windows**: pwsh-native syntax — no `&&` chaining (use `;` or separate calls). Quote paths with spaces.
- **Don't run interactive commands**: no `git rebase -i`, no `flutter create` prompts. Pre-fill all args.

## Slash commands (`.claude/commands/`)

| Command | Purpose |
|---------|---------|
| `/add-feature` | Scaffold a Clean Architecture feature module — alias of skill `add-feature` |
| `/add-api` | Wire a backend endpoint end-to-end — alias of skill `add-api` |
| `/add-language` | Add or update localization strings — alias of skill `add-language` |
| `/new-screen` | Add a page + BLoC to an existing feature |
| `/review` | Audit code against project conventions in canonical `AGENTS.md` |
| `/test` | Write unit/widget tests (prefer `flutter-add-widget-test` / `dart-add-unit-test` skills) |
| `/update-docs` | Update `CHANGELOG.md` + `DOCUMENTATION_UPDATE_SUMMARY.md` + `CURRENT_STATUS.md` |
| `/clean-build` | `flutter clean` + `pub get` + `build_runner` |

The first three are content-identical to skills in [`.agents/skills/`](.agents/skills/). The other five are Claude-Code-only.

## Skill catalog (full)

22 skills total live in [`.agents/skills/`](.agents/skills/) (3 project-tuned + 19 official Flutter & Dart). Full catalog in [`AGENTS.md`](AGENTS.md) § Available Skills.

## Where to look

| Need | File |
|------|------|
| Project conventions | [`AGENTS.md`](AGENTS.md) |
| Onboarding & doc-map | [`tech_readme_files/INDEX.md`](tech_readme_files/INDEX.md) |
| Troubleshooting | [`tech_readme_files/TROUBLESHOOTING.md`](tech_readme_files/TROUBLESHOOTING.md) |
| Common pitfalls | [`tech_readme_files/COMMON_PITFALLS.md`](tech_readme_files/COMMON_PITFALLS.md) |
| Architecture decisions | [`tech_readme_files/decisions/`](tech_readme_files/decisions/) |
| Glossary | [`tech_readme_files/GLOSSARY.md`](tech_readme_files/GLOSSARY.md) |
