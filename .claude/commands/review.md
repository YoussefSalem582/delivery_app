Audit the selected code (or recent diff) against canonical `AGENTS.md`:

- Clean Architecture layer boundaries
- BLoCs call use cases, not repositories; Cubits for lighter UI state
- Design tokens (AppColors, AppSpacing) — no hardcoded colors/spacing
- Localization — no raw user-facing strings
- Offline: cache + pending sync where applicable
- RouteNames — no hardcoded paths
- Geocoding via Nominatim repository — no demo place catalog or GPS-offset coords
- External APIs (Nominatim/OSRM): offline guards, no secrets in source
- Branding assets: `logo.svg` in-app, `logo.png`/`app_icon.png` for native codegen

Output a concise checklist of violations and suggested fixes.
