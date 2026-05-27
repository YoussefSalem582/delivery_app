# ADR 004: easy_localization JSON (not ARB)

**Status:** Accepted

## Decision

Use `easy_localization` with JSON files in `assets/translations/` instead of Flutter gen-l10n ARB.

## Rationale

- Simpler JSON editing for MVP / freelance demos
- Matches existing codebase; no `flutter gen-l10n` step

## Consequences

- No compile-time key validation (unlike ARB)
- Agents must update both `en.json` and `ar.json` manually
