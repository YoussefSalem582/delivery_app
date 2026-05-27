# Codex CLI Instructions — Shim

> **Canonical conventions live in [`../AGENTS.md`](../AGENTS.md).** Read the canonical doc first; this file contains **only Codex-specific runtime guidance**.

## Codex Runtime Conventions

- **Approval mode**: Default `auto-edit` for documentation, `suggest` for `lib/**`, `ios/**`, `android/**`.
- **Sandbox**: Filesystem writes scoped to `delivery_app/` only.
- **Network**: May run `flutter pub get`, `flutter analyze`, `flutter test`, `dart format`, `npx skills update`, and `scripts/*.ps1` without prompting. Other network/git commands need explicit approval.
- **Shell**: Windows 11 / PowerShell — prefer `.ps1` scripts; no bash `&&` chaining.

## Codex-Specific Workflow Tips

1. **Plan first** — numbered list of files + intended changes.
2. **Edit one layer at a time** — domain → data → presentation.
3. **Verify between layers** — `flutter analyze` after each layer.
4. **Update docs last** — CHANGELOG, DOCUMENTATION_UPDATE_SUMMARY, CURRENT_STATUS.

### Tool Selection

- Prefer `apply_patch` over shell `sed`/`awk`.
- Prefer `rg` over `grep`.
- Use `flutter analyze` as the project-wide lint check.

## Skills

Codex reads [`../.agents/skills/`](../.agents/skills/) — 22 skills (3 project-tuned + 19 official). Prefer `add-feature`, `add-api`, `add-language` for overlapping workflows.

## Hard Constraints (DO NOT)

- Do NOT hardcode secrets, API URLs, hex colours, or pixel values — use `EnvConfig`, `AppColors`, `AppSpacing`.
- Do NOT use raw strings in UI — use `'key'.tr()` in both EN + AR JSON files.
- Do NOT push to remote or amend pushed commits without explicit permission.
- Do NOT skip pre-commit hooks without explicit permission.
- Do NOT manually edit official skills tracked in `../skills-lock.json` — re-sync via `npx skills update`.

## Where to look

| Need | File |
|------|------|
| Canonical conventions | [`../AGENTS.md`](../AGENTS.md) |
| Onboarding | [`../tech_readme_files/INDEX.md`](../tech_readme_files/INDEX.md) |
| Troubleshooting | [`../tech_readme_files/TROUBLESHOOTING.md`](../tech_readme_files/TROUBLESHOOTING.md) |
