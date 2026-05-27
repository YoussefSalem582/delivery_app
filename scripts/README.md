# Doc scripts — run from repo root

| Script | Purpose |
|--------|---------|
| `scripts/docs/sync_ai_ignores.ps1` | Regenerate AI ignore files from template |
| `scripts/docs/check_docs_freshness.ps1` | Verify pubspec version in README / CHANGELOG / CURRENT_STATUS |
| `scripts/docs/check_skills_drift.ps1` | Verify official skills match `skills-lock.json` |

Root shims (backward-compatible):

- `scripts/sync_ai_ignores.ps1` → `scripts/docs/sync_ai_ignores.ps1`
- `scripts/check_docs_freshness.ps1` → `scripts/docs/check_docs_freshness.ps1`
- `scripts/check_skills_drift.ps1` → `scripts/docs/check_skills_drift.ps1`
