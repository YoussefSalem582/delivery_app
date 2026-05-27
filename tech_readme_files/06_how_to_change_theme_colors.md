# 06 — How to Change Theme Colors

## Design tokens

| File | Purpose |
|------|---------|
| `lib/config/theme/app_colors.dart` | Color tokens |
| `lib/config/theme/app_spacing.dart` | Spacing + radius |
| `lib/config/theme/light_theme.dart` | Light `ThemeData` |
| `lib/config/theme/dark_theme.dart` | Dark `ThemeData` |
| `lib/config/theme/app_theme.dart` | Theme builder |

## Rules

- Add new colors to `AppColors`, never inline hex in widgets
- Wire into `ColorScheme` in light/dark theme files
- Settings → theme toggle via `SettingsCubit`

## Stitch design reference

HTML mocks under `design/stitch/screens/` — use as visual reference only; implement with Flutter tokens.
