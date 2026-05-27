Audit the selected code (or recent diff) against canonical `AGENTS.md`:

- Clean Architecture layer boundaries
- BLoCs call use cases, not repositories
- Design tokens (AppColors, AppSpacing) — no hardcoded colors/spacing
- Localization — no raw user-facing strings
- Offline: cache + pending sync where applicable
- RouteNames — no hardcoded paths

Output a concise checklist of violations and suggested fixes.
