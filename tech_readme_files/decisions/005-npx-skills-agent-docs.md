# ADR 005: npx skills for Agent Documentation

**Status:** Accepted

## Decision

Mirror Technology 92 agent doc layout:

- Canonical `AGENTS.md` + per-tool shims
- `.agents/skills/` with 3 project-tuned + 19 official Flutter/Dart skills
- `skills-lock.json` + drift check scripts
- Doc hygiene CI in `.github/workflows/docs.yml`

## Consequences

- Consistent agent behavior across Cursor, Claude, Codex, Copilot
- Official skills updated via `npx skills update`
